//
//  Recorder.swift
//  AudioRecorder
//
//  Created by Smetankin Dmitry on 6/21/19.
//  Copyright © 2019 Smetankin. All rights reserved.
//

import AVFoundation

class Recorder: NSObject {
    private lazy var recordingSession = AVAudioSession.sharedInstance()

    private var recordFileURL: URL?
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var completion: ((Result) -> Void)?
    private var recordDurationProgress: ((TimeInterval) -> Void)?

    private let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey: 44100,
                            AVNumberOfChannelsKey: 1,
                            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]

    private let maxDuration: TimeInterval = 30

    func startRecording(with completion: @escaping (Result) -> Void, recordDurationProgress: @escaping (TimeInterval) -> Void) {
        self.completion = completion
        self.recordDurationProgress = recordDurationProgress

        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("fullRecord.m4a") else {
            completion(.failure(Error.documentsDirectoryNotFound))
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            self.recordFileURL = url

            do {
                try self.recordingSession.setCategory(AVAudioSession.Category.playAndRecord)
                try self.recordingSession.setActive(true, options: .notifyOthersOnDeactivation)
                self.audioRecorder = try AVAudioRecorder(url: url, settings: self.settings)
                self.audioRecorder?.prepareToRecord()
                self.audioRecorder?.delegate = self
            } catch {
                completion(.failure(error))
                return
            }

            self.recordingSession.requestRecordPermission { [weak self] granted in
                guard let self = self else { return }

                if granted {
                    self.audioRecorder?.record(forDuration: 30)
                    self.scheduleTimer()
                } else {
                    self.completion?(.failure(Error.permissionDenied))
                }
            }
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
    }

    private func scheduleTimer() {
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] _ in
                guard let self = self, var duration = self.audioRecorder?.currentTime else { return }
                duration = duration > self.maxDuration ? self.maxDuration : duration
                self.recordDurationProgress?(duration)
            })
        }
    }
}

extension Recorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        handleFinish()
        if let url = recordFileURL, flag {
            completion?(.success(url))
        } else {
            completion?(.failure(Error.failedToEncodeAudio))
        }
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Swift.Error?) {
        handleFinish()
        if let error = error {
            completion?(.failure(error))
        } else {
            completion?(.failure(Error.failedToEncodeAudio))
        }
    }

    private func handleFinish() {
        try? recordingSession.setActive(false, options: .notifyOthersOnDeactivation)
        timer?.invalidate()
        timer = nil
        audioRecorder = nil
    }
}

extension Recorder {
    enum Result {
        case success(URL)
        case failure(Swift.Error)
    }

    enum Error: LocalizedError {
        case documentsDirectoryNotFound
        case failedToEncodeAudio
        case permissionDenied
    }
}
