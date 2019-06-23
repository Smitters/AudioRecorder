//
//  AssetTrimmerTests.swift
//  AudioRecorderTests
//
//  Created by Smetankin Dmitry on 6/23/19.
//  Copyright © 2019 Smetankin. All rights reserved.
//

import XCTest
import AVFoundation
@testable import AudioRecorder

class AssetTrimmerTests: XCTestCase {

    var trimmer: AssetTrimmer!

    override func setUp() {
        super.setUp()

        // mock file with 15.833 sec duration
        let path = Bundle(for: type(of: self)).path(forResource: "sample_44100hz_16s", ofType: "m4a") ?? ""
        let sampleUrl = URL(fileURLWithPath: path)
        trimmer = AssetTrimmer(fullRecord: sampleUrl)
    }

    override func tearDown() {
        trimmer = nil

        try? FileManager.default.removeItem(at: Directories.recordsDirectory)
        super.tearDown()
    }

    func testTimeRanges() {
        let timeRanges = trimmer.timeRanges(splitCount: 4)

        guard let lastTimeRange = timeRanges.last else {
            XCTFail()
            return
        }

        let startTimeOfLastTimeRange = CMTimeGetSeconds(lastTimeRange.start)
        let endTimeOfLastTimeRange = CMTimeGetSeconds(lastTimeRange.end)

        XCTAssertEqual(startTimeOfLastTimeRange, 11.8747)
        XCTAssertEqual(endTimeOfLastTimeRange, 15.833)
        XCTAssertEqual(timeRanges.count, 4)
    }

    func testTimeRangesForEmptySlitCount() {
        let timeRanges = trimmer.timeRanges(splitCount: 0)
        XCTAssertEqual(timeRanges.count, 0)
    }

    func testTimeRangesForSingleSplitCount() {
        let timeRanges = trimmer.timeRanges(splitCount: 1)

        guard let lastTimeRange = timeRanges.last else {
            XCTFail()
            return
        }

        let startTimeOfLastTimeRange = CMTimeGetSeconds(lastTimeRange.start)
        let endTimeOfLastTimeRange = CMTimeGetSeconds(lastTimeRange.end)

        XCTAssertEqual(startTimeOfLastTimeRange, 0)
        XCTAssertEqual(endTimeOfLastTimeRange, 15.833)
        XCTAssertEqual(timeRanges.count, 1)
    }

    func testTimeRangesForNegativeSplitCount() {
        let timeRanges = trimmer.timeRanges(splitCount: -10)
        XCTAssertEqual(timeRanges.count, 0)
    }

    func testSafeFileName() {
        let inputFileName = "File: name with \\ in the middle and / on the end %"
        let outputFileName = "File_ name with _ in the middle and _ on the end _"
        XCTAssertEqual(trimmer.safeFileName(from: inputFileName), outputFileName)
    }

    func testAssetTrimm() {
        guard let timeRange = trimmer.timeRanges(splitCount: 2).last else {
            XCTFail()
            return
        }

        let trimExpectation = expectation(description: "Trim asset expectation")

        trimmer.trimAsset(with: timeRange, outputFileName: "output/File/Name") { result in
            switch result {
            case .success(let safeFileName):
                let url = Directories.recordsDirectory.appendingPathComponent(safeFileName)
                let trimmedAsset = AVAsset(url: url)
                let trimmedAssetDuration = CMTimeGetSeconds(trimmedAsset.duration)

                XCTAssertEqual(safeFileName, "output_File_Name.m4a")
                XCTAssertEqual(trimmedAssetDuration, 7.915555555555556)
            default:
                XCTFail("Failed to trimm asset")
            }
            trimExpectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
}
