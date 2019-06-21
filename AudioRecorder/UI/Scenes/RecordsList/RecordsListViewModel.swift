//
//  RecordListViewModel.swift
//  AudioRecorder
//
//  Created by Smetankin Dmitry on 6/20/19.
//  Copyright © 2019 Smetankin. All rights reserved.
//

import Foundation

class RecordsListViewModel {
    private let model: RecordsListModel
    private let cordinator: CoordinatorType

    init(model: RecordsListModel, cordinator: CoordinatorType) {
        self.model = model
        self.cordinator = cordinator
    }

    func addNewRecord() {
        cordinator.openAddNewRecordController()
    }
}
