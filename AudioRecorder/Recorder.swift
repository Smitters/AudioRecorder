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

    private let recordFileURL = Directories.documentsDirectory.appendingPathComponent("fullRecord.m4a")
    private var audioRecorder: AVAudioRecorder?
    private var displayLink: CADisplayLink?
    private var completion: ((Result) -> Void)?
    private var recordDurationProgress: ((TimeInterval) -> Void)?

    private let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey: 44100,
                            AVNumberOfChannelsKey: 1,
                            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]

    private let maxDuration: TimeInterval = 30
    private var isCanceled = false

    func startRecording(with completion: @escaping (Result) -> Void, recordDurationProgress: @escaping (TimeInterval) -> Void) {
        self.completion = completion
        self.recordDurationProgress = recordDurationProgress
        isCanceled = false

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.recordingSession.setCategory(AVAudioSession.Category.playAndRecord)
                try self.recordingSession.setActive(true, options: .notifyOthersOnDeactivation)
                self.audioRecorder = try AVAudioRecorder(url: self.recordFileURL, settings: self.settings)
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
                    self.displayLink = CADisplayLink(target: self, selector: #selector(self.udateDuration))
                    self.displayLink?.add(to: .main, forMode: .common)
                } else {
                    self.completion?(.failure(Error.permissionDenied))
                }
            }
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
    }

    func cancel() {
        if audioRecorder?.isRecording == true {
            isCanceled = true
            audioRecorder?.stop()
            audioRecorder?.deleteRecording()
        }
    }

    @objc private func udateDuration() {
        guard var duration = audioRecorder?.currentTime else { return }
        duration = duration > maxDuration ? maxDuration : duration
        recordDurationProgress?(duration)
    }
}

extension Recorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        handleFinish()
        guard !isCanceled else {
            completion?(.canceled)
            return
        }

        if flag {
            completion?(.success(recordFileURL))
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
        displayLink?.invalidate()
        displayLink = nil
        audioRecorder = nil
    }
}

extension Recorder {
    enum Result {
        case success(URL)
        case failure(Swift.Error)
        case canceled
    }

    enum Error: LocalizedError {
        case failedToEncodeAudio
        case permissionDenied
    }
}
