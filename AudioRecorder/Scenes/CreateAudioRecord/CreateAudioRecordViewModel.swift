//
//  CreateAudioRecordViewModel.swift
//  AudioRecorder
//
//  Created by Smetankin Dmitry on 6/20/19.
//  Copyright © 2019 Smetankin. All rights reserved.
//

import AVFoundation
import RxSwift
import RxCocoa

private let defaultDurationValue = "00.00"

class CreateAudioRecordViewModel {
    private let model: CreateAudioRecordModel
    private let coordinator: CoordinatorType

    let recordDuration = BehaviorRelay<String>(value: defaultDurationValue)
    let isRecording: BehaviorRelay<Bool>

    let disposeBag = DisposeBag()

    init(model: CreateAudioRecordModel, coordinator: CoordinatorType) {
        self.model = model
        self.coordinator = coordinator
        self.isRecording = model.isRecording

        model.recordDuration.map(timeString).bind(to: recordDuration).disposed(by: disposeBag)
        model.recordResult.observeOn(MainScheduler.instance).subscribe(onNext: { record in
            debugPrint("saved record \(record)")
        }, onError: { [weak self] (error) in
            self?.coordinator.showError(error, completion: { [weak self] in
                self?.coordinator.dismiss()
            })
        }, onCompleted: { [weak self] in
            self?.coordinator.dismiss()
        }).disposed(by: disposeBag)
    }

    func toggleRecord() {
        if model.isRecording.value {
            model.stopRecording()
        } else {
            model.startRecording()
        }
    }

    func cancel() {
        model.cancelRecording()
        coordinator.dismiss()
    }

    private func timeString(_ time: TimeInterval) -> String {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2

        return formatter.string(from: NSNumber(value: time)) ?? defaultDurationValue
    }
}
