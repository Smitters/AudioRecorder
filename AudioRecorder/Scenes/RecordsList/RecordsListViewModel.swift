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

    let records = BehaviorSubject<[Record]>(value: [])

    init(model: RecordsListModel, cordinator: CoordinatorType) {
        self.model = model
        self.cordinator = cordinator

        model.recordsSubject.map(convert).bind(to: records).disposed(by: disposeBag)
    }

    func addNewRecord() {
        cordinator.openAddNewRecordController()
    }
}

extension RecordsListViewModel {
    struct Record {
        let name: String
        let fileUrl: URL
        let duration: Double
    }

    func convert(objects: [AudioRecord]) -> [Record] {
        return objects.map { Record(name: $0.name, fileUrl: $0.fileUrl, duration: $0.duration) }
    }
}
