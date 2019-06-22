//
//  AssetTrimmer.swift
//  AudioRecorder
//
//  Created by Smetankin Dmitry on 6/21/19.
//  Copyright © 2019 Smetankin. All rights reserved.
//

import AVFoundation

class AssetTrimmer {
    private let originalAsset: AVAsset

    init(fullRecord: URL) {
        originalAsset = AVAsset(url: fullRecord)
    }

    func timeRanges(splitCount: Int) -> [CMTimeRange] {
        guard splitCount > 0 else { return [] }

        let durationInSeconds = CMTimeGetSeconds(originalAsset.duration)
        var timeRanges = [CMTimeRange]()

        for i in 0..<splitCount {
            let startTime = CMTime(seconds: durationInSeconds * Double(i) / Double(splitCount), preferredTimescale: 1)
            let endTime = CMTime(seconds: durationInSeconds * Double(i + 1) / Double(splitCount), preferredTimescale: 1)
            let range = CMTimeRange(start: startTime, end: endTime)
            timeRanges.append(range)
        }
        return timeRanges
    }

    func trimAsset(with timeRange: CMTimeRange, outputFileName: String, completion: @escaping (Result) -> Void) {
        let recordsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                                                  .appendingPathComponent("records", isDirectory: true)

        guard let exporter = AVAssetExportSession(asset: originalAsset, presetName: AVAssetExportPresetAppleM4A) else {
            completion(.failed(Error.failedToInstantiateExporter))
            return
        }

        do {
            try FileManager.default.createDirectory(at: recordsDirectory, withIntermediateDirectories: true)
        } catch {
            completion(.failed(Error.exportFailed(error)))
        }

        let safeName = safeFileName(from: outputFileName)
        let outputURL = recordsDirectory.appendingPathComponent(safeName).appendingPathExtension("m4a")

        exporter.outputURL = outputURL
        exporter.outputFileType = AVFileType.m4a
        exporter.timeRange = timeRange

        exporter.exportAsynchronously {
            switch exporter.status {
            case .failed:
                completion(.failed(Error.exportFailed(exporter.error)))
            case .cancelled:
                completion(.failed(Error.canceled))
            case .completed:
                completion(.success(outputURL))
            default:
                break
            }
        }
    }

    func safeFileName(from originalFileName: String) -> String {
        var invalidCharacters = CharacterSet(charactersIn: ":/\\%")
        invalidCharacters.formUnion(.newlines)
        invalidCharacters.formUnion(.illegalCharacters)
        invalidCharacters.formUnion(.controlCharacters)
        return originalFileName.components(separatedBy: invalidCharacters).joined(separator: "_")
    }
}

extension AssetTrimmer {

    /// Result of the trimming
    ///
    /// - success with URL of the trimmed asset
    /// - failed with error
    enum Result {
        case success(URL)
        case failed(Error)
    }

    enum Error: LocalizedError {
        case exportFailed(Swift.Error?)
        case failedToInstantiateExporter
        case canceled
    }
}
