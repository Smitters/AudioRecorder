//
//  RecordDetailView.swift
//  AudioRecorder
//
//  Created by Smetankin Dmitry on 6/23/19.
//  Copyright © 2019 Smetankin. All rights reserved.
//

import Foundation
import UIKit
import Accelerate

class WaveView: UIView {

    var wavePoints: [CGFloat] = [] {
        didSet {
            setNeedsDisplay()
        }
    }

    var progress: Float = 0 {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        let topWavePath = UIBezierPath()
        let bottomWavePath = UIBezierPath()

        let playedTopWavePath = UIBezierPath()
        let playedBottomWavePath = UIBezierPath()

        topWavePath.lineWidth = WaveView.lineWidth
        bottomWavePath.lineWidth = WaveView.lineWidth
        playedTopWavePath.lineWidth = WaveView.lineWidth
        playedBottomWavePath.lineWidth = WaveView.lineWidth

        let xStep: CGFloat = WaveView.lineWidth + WaveView.marginBetweenLines

        let playedPoints = Int(Float(wavePoints.count) * progress)

        playedTopWavePath.move(to: CGPoint(x: bounds.width / 2, y: rect.height / 2))
        playedBottomWavePath.move(to: CGPoint(x: bounds.width / 2, y: rect.height / 2))

        for point in wavePoints[..<playedPoints].reversed() {
            let nextPoint = CGPoint(x: playedTopWavePath.currentPoint.x - xStep,
                                    y: playedTopWavePath.currentPoint.y)

            playedTopWavePath.move(to: nextPoint)
            playedBottomWavePath.move(to: nextPoint)

            playedTopWavePath.addLine(to: CGPoint(x: playedTopWavePath.currentPoint.x,
                                            y: playedTopWavePath.currentPoint.y - point * rect.height - 1))

            playedBottomWavePath.addLine(to: CGPoint(x: playedBottomWavePath.currentPoint.x,
                                               y: playedBottomWavePath.currentPoint.y + point * 0.75 * rect.height + 1))
            playedTopWavePath.close()
            playedBottomWavePath.close()
        }

        #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).set()
        playedTopWavePath.stroke()
        playedTopWavePath.fill()

        #colorLiteral(red: 0.6962410212, green: 0.6962410212, blue: 0.6962410212, alpha: 1).set()
        playedBottomWavePath.stroke()
        playedBottomWavePath.fill()

        topWavePath.move(to: CGPoint(x: bounds.width / 2, y: rect.height / 2))
        bottomWavePath.move(to: CGPoint(x: bounds.width / 2, y: rect.height / 2))

        for point in wavePoints[playedPoints...] {
            let nextPoint = CGPoint(x: topWavePath.currentPoint.x + xStep,
                                    y: topWavePath.currentPoint.y)

            topWavePath.move(to: nextPoint)
            bottomWavePath.move(to: nextPoint)

            topWavePath.addLine(to: CGPoint(x: topWavePath.currentPoint.x,
                                            y: topWavePath.currentPoint.y - point * 1.5 * rect.height - 1))

            bottomWavePath.addLine(to: CGPoint(x: bottomWavePath.currentPoint.x,
                                               y: bottomWavePath.currentPoint.y + point * rect.height + 1))
            topWavePath.close()
            bottomWavePath.close()
        }

        #colorLiteral(red: 0, green: 0.5936083198, blue: 0.8936790824, alpha: 1).set()
        topWavePath.stroke()
        topWavePath.fill()

        #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1).set()
        bottomWavePath.stroke()
        bottomWavePath.fill()
    }
}

extension WaveView {
    static let lineWidth: CGFloat = 2
    static let marginBetweenLines: CGFloat = 0.5
    static let lineDurationInSeconds = 0.01
}
