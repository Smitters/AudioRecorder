//
//  TimeIntervalExtensions.swift
//  AudioRecorder
//
//  Created by Smetankin Dmitry on 6/23/19.
//  Copyright © 2019 Smetankin. All rights reserved.
//

import Foundation

extension TimeInterval {
    var timeString: String {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2

        return formatter.string(from: NSNumber(value: self)) ?? "00.00"
    }
}
