//
//  RecordPlayerTests.swift
//  AudioRecorderTests
//
//  Created by Smetankin Dmitry on 6/23/19.
//  Copyright © 2019 Smetankin. All rights reserved.
//

import XCTest
import AVFoundation
import RxSwift

@testable import AudioRecorder

class RecordPlayerTests: XCTestCase {

    var player: RecordPlayer!
    var disposeBag: DisposeBag!
    let fileName = "sample_44100hz_16s.m4a"

    override func setUp() {
        super.setUp()

        disposeBag = DisposeBag()
        player = RecordPlayer()
        player.recordDirectory = Bundle(for: type(of: self)).bundleURL
    }

    override func tearDown() {
        player = nil
        disposeBag = nil

        super.tearDown()
    }

    func testPlayer() {
        let startPlayingExpectation = expectation(description: "startPlayingExpectation")

        player.playerProgress.subscribe(onNext: { (progress) in
            if progress != 0 {
                startPlayingExpectation.fulfill()
            }
        }).disposed(by: disposeBag)

        player.play(fileName: fileName)

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertTrue(player.isPlaying.value)

        let stopPlayingExpectation = expectation(description: "stopPlayingExpectation")

        player.isPlaying.subscribe(onNext: { isPlaying in
            if isPlaying == false {
                stopPlayingExpectation.fulfill()
            }
        }).disposed(by: disposeBag)

        player.stop()

        waitForExpectations(timeout: 5, handler: nil)
    }
}
