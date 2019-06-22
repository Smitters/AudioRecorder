//
//  CreateAudioRecordModel.swift
//  AudioRecorder
//
//  Created by Smetankin Dmitry on 6/20/19.
//  Copyright © 2019 Smetankin. All rights reserved.
//

import RxSwift
import RxCocoa
import AVFoundation

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

    // MARK: - Recording

    func startRecording() {
        isRecording.accept(true)
        recorder.startRecording(with: { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let url):
                self.isRecording.accept(false)
                self.splitAndSaveAudio(url: url).bind(to: self.recordResult).disposed(by: self.disposeBag)
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

    // MARK: - Splitting

    func splitAndSaveAudio(url: URL) -> Observable<URL> {

        let splitter = AssetTrimmer(fullRecord: url)
        let timeRanges = splitter.timeRanges(splitCount: 3)

        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        let fileNamePrefix = formatter.string(from: currentDate)

        var observables = [Observable<URL>]()

        for (index, range) in timeRanges.enumerated() {
            let fileName = "\(fileNamePrefix) part\(index + 1)"
            observables.append(trimAssetAndSave(splitter: splitter, range: range, fileName: fileName))
        }

        return Observable.merge(observables)
    }

    private func trimAssetAndSave(splitter: AssetTrimmer, range: CMTimeRange, fileName: String) -> Observable<URL> {
        return Observable.create({ (observer) -> Disposable in
            splitter.trimAsset(with: range, outputFileName: fileName) { result in
                switch result {
                case .success(let url):
                    observer.onNext(url)
                    observer.onCompleted()
                case .failed(let error):
                    observer.onError(error)
                }
            }

            return Disposables.create()
        })
    }
}
