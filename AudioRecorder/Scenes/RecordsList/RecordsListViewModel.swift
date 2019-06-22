//
//  RecordListViewModel.swift
//  AudioRecorder
//
//  Created by Smetankin Dmitry on 6/20/19.
//  Copyright © 2019 Smetankin. All rights reserved.
//

import RxSwift

class RecordsListViewModel {
    private let model: RecordsListModel
    private let cordinator: CoordinatorType
    private let disposeBag = DisposeBag()

    let records: BehaviorSubject<[AudioRecord]>

    init(model: RecordsListModel, cordinator: CoordinatorType) {
        self.model = model
        self.cordinator = cordinator
        self.records = model.recordsSubject
    }

    func addNewRecord() {
        cordinator.openAddNewRecordController()
    }
}
