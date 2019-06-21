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
    private let cordinator: CoordinatorType

    let recordDuration = BehaviorSubject<String>(value: defaultDurationValue)
    let isSaving = BehaviorSubject(value: false)

    let disposeBag = DisposeBag()

    init(model: CreateAudioRecordModel, cordinator: CoordinatorType) {
        self.model = model
        self.cordinator = cordinator

        model.recordDuration.map(timeString).bind(to: recordDuration).disposed(by: disposeBag)
    }

    func toggleRecord() {
        if model.isRecording.value {
            model.stopRecording()
        } else {
            model.startRecording()
        }
    }

    private func timeString(_ time: TimeInterval) -> String {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2

        return formatter.string(from: NSNumber(value: time)) ?? defaultDurationValue
    }
}
