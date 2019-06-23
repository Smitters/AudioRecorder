//
//  RecordDetailsViewModel.swift
//  AudioRecorder
//
//  Created by Smetankin Dmitry on 6/22/19.
//  Copyright © 2019 Smetankin. All rights reserved.
//

import RxSwift
import RxCocoa
import Accelerate
import AVFoundation

class RecordDetailsViewModel {

    private let url: URL
    private let record: AudioRecord
    private let recordPlayer = RecordPlayer()

    let wavePoints = BehaviorRelay<[CGFloat]>(value: [])
    let playerProgress: BehaviorRelay<Float>
    let durationText: Observable<String>
    let isPlaying: BehaviorRelay<Bool>
    let name: String

    init(record: AudioRecord) {
        self.record = record
        url = Directories.recordsDirectory.appendingPathComponent(record.fileName)
        playerProgress = recordPlayer.playerProgress
        isPlaying = recordPlayer.isPlaying
        name = record.name

        let duration = record.duration
        durationText = playerProgress.map { (progress) -> String in
            return String("\(TimeInterval(duration * TimeInterval(progress)).timeString) | \(duration.timeString)")
        }
    }

    func toggleStart() {
        if isPlaying.value {
            recordPlayer.stop()
        } else {
            recordPlayer.play(fileName: record.fileName)
        }
    }

    func createWavePoints() {
        guard let file = try? AVAudioFile(forReading: url),
            let format = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                         sampleRate: file.fileFormat.sampleRate,
                                         channels: file.fileFormat.channelCount,
                                         interleaved: false),
            let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length)) else {

            return
        }

        try? file.read(into: buf)

        let floatValues = Array(UnsafeBufferPointer(start: buf.floatChannelData?[0], count: Int(buf.frameLength)))
        let samplesPerLine = file.fileFormat.sampleRate * WaveView.lineDurationInSeconds

        var processingBuffer = [Float](repeating: 0, count: floatValues.count)
        vDSP_vabs(floatValues, 1, &processingBuffer, 1, vDSP_Length(floatValues.count))

        let filter = [Float](repeating: 1.0 / Float(samplesPerLine), count: Int(samplesPerLine))
        let linesCount = Int(floatValues.count / Int(samplesPerLine))
        var wavePointsData = [Float](repeating: 0, count: linesCount)

        vDSP_desamp(processingBuffer, Int(samplesPerLine), filter, &wavePointsData, UInt(linesCount), UInt(samplesPerLine))

        wavePoints.accept(wavePointsData.map { CGFloat($0) })
    }
}
