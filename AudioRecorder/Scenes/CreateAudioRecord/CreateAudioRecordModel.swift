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

    private let persistence: Persistence
    private lazy var recorder = Recorder()
    private let disposeBag = DisposeBag()

    let recordResult = PublishSubject<AudioRecord>()
    let recordDuration = BehaviorRelay<TimeInterval>(value: 0)
    let isRecording = BehaviorRelay(value: false)

    init(persistence: Persistence) throws {
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
            case .canceled:
                self.isRecording.accept(false)
            }
        }, recordDurationProgress: { [weak self] timeInterval in
            self?.recordDuration.accept(timeInterval)
        })
    }

    func stopRecording() {
        recorder.stopRecording()
    }

    func cancelRecording() {
        recorder.cancel()
    }

    // MARK: - Splitting

    func splitAndSaveAudio(url: URL) -> Observable<AudioRecord> {

        let splitter = AssetTrimmer(fullRecord: url)
        let timeRanges = splitter.timeRanges(splitCount: 3)

        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd | HH:mm:ss"
        let fileNamePrefix = formatter.string(from: currentDate)

        var observables = [Single<AudioRecord>]()

        for (index, range) in timeRanges.enumerated() {
            let fileName = "\(fileNamePrefix) (part-\(index + 1))"
            observables.append(trimAssetAndSave(splitter: splitter, range: range, name: fileName))
        }

        return Observable.from(observables).merge(maxConcurrent: 3).do(onError: { [weak self] _ in
            self?.persistence.saveChanges()
        }, onCompleted: { [weak self] in
            self?.persistence.saveChanges()
        })
    }

    private func trimAssetAndSave(splitter: AssetTrimmer, range: CMTimeRange, name: String) -> Single<AudioRecord> {
        return Single.create(subscribe: { [weak self] (single) -> Disposable in
            splitter.trimAsset(with: range, outputFileName: name) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let fileName):
                    let duration: Double = CMTimeGetSeconds(range.duration)
                    DispatchQueue.main.async {
                        let record = AudioRecord(name: name, fileName: fileName, duration: duration, insertIntoManagedObjectContext: self.persistence.viewContext)
                        single(.success(record))
                    }
                case .failed(let error):
                    single(.error(error))
                }
            }

            return Disposables.create()
        })
    }
}
