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

    let waveViewWidth = BehaviorRelay<CGFloat>(value: 0)
    let wavePoints = BehaviorRelay<[CGFloat]>(value: [])

    init(recordName: String) {
        url = Directories.recordsDirectory.appendingPathComponent(recordName)
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

        vDSP_desamp(processingBuffer,
                    Int(samplesPerLine),
                    filter, &wavePointsData,
                    UInt(linesCount),
                    UInt(samplesPerLine))

        let width = CGFloat(linesCount) * (WaveView.lineWidth + WaveView.marginBetweenLines)
        waveViewWidth.accept(width)
        wavePoints.accept(wavePointsData.map { CGFloat($0) })
    }
}
