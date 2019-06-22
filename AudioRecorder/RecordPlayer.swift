//
//  RecordPlayer.swift
//  AudioRecorder
//
//  Created by Smetankin Dmitry on 6/22/19.
//  Copyright © 2019 Smetankin. All rights reserved.
//

import AVFoundation
import RxCocoa

class RecordPlayer: NSObject {

    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?

    let isPlaying = BehaviorRelay(value: false)
    let playerProgress = BehaviorRelay<Float>(value: 0)
    let backgroundQueue = DispatchQueue(label: "play_sound_queue", qos: .userInitiated)

    func play(fileName: String) {
        if self.audioPlayer != nil {
            self.audioPlayer?.stop()
            self.cleanup()
        }

        backgroundQueue.async {
            do {
                let url = Directories.recordsDirectory.appendingPathComponent(fileName)
                self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                self.audioPlayer?.delegate = self

                if self.audioPlayer?.play() == true {
                    self.isPlaying.accept(true)
                    self.scheduleTimer()
                }
            } catch {
                debugPrint(error)
            }
        }
    }

    func stop() {
        backgroundQueue.async {
            self.audioPlayer?.stop()
            self.cleanup()
        }
    }

    private func scheduleTimer() {
        timer = Timer(timeInterval: 0.1, repeats: true, block: { [weak self] _ in
            guard let player = self?.audioPlayer else { return }

            let progress = player.currentTime / player.duration
            self?.playerProgress.accept(Float(progress))
        })

        RunLoop.main.add(timer!, forMode: .common)
    }
}

extension RecordPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        cleanup()
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        cleanup()
    }

    private func cleanup() {
        backgroundQueue.async {
            self.isPlaying.accept(false)
            self.playerProgress.accept(0)

            self.timer?.invalidate()

            self.audioPlayer = nil
            self.timer = nil
        }
    }
}
