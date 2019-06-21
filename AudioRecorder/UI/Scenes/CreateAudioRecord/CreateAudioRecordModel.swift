//
//  CreateAudioRecordModel.swift
//  AudioRecorder
//
//  Created by Smetankin Dmitry on 6/20/19.
//  Copyright © 2019 Smetankin. All rights reserved.
//

import RxSwift
import RxCocoa

class CreateAudioRecordModel {

    private let persistence: PersistenceType
    private lazy var recorder = Recorder()
    private let disposeBag = DisposeBag()

    let recordResult = PublishSubject<URL>()
    let recordDuration = BehaviorSubject<TimeInterval>(value: 0)
    let isRecording = BehaviorRelay(value: false)

    init(persistence: PersistenceType) throws {
        self.persistence = persistence
    }

    func startRecording() {
        isRecording.accept(true)
        recorder.startRecording(with: { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let url):
                self.isRecording.accept(false)
                self.recordResult.onNext(url)
                self.recordResult.onCompleted()
            case .failure(let error):
                self.isRecording.accept(false)
                self.recordResult.onError(error)
            }
        }, recordDurationProgress: { [weak self] timeInterval in
            self?.recordDuration.onNext(timeInterval)
        })
    }

    func stopRecording() {
        recorder.stopRecording()
    }
}
