//
//  Directories.swift
//  AudioRecorder
//
//  Created by Smetankin Dmitry on 6/22/19.
//  Copyright © 2019 Smetankin. All rights reserved.
//

import Foundation

enum Directories {
    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    static let recordsDirectory = documentsDirectory.appendingPathComponent("records", isDirectory: true)
}
