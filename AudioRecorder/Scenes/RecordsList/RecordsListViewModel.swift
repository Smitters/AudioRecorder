//
//  RecordListViewModel.swift
//  AudioRecorder
//
//  Created by Smetankin Dmitry on 6/20/19.
//  Copyright © 2019 Smetankin. All rights reserved.
//

import RxSwift
import RxCocoa

class RecordsListViewModel {
    private let model: RecordsListModel
    private let cordinator: CoordinatorType
    private let disposeBag = DisposeBag()
    private let recordPlayer = RecordPlayer()

    let records: BehaviorRelay<[AudioRecord]>
    let playedItemProgress: BehaviorRelay<Float>
    let isPlayed: BehaviorRelay<Bool>

    var lastPlayedRow: Int?

    init(model: RecordsListModel, cordinator: CoordinatorType) {
        self.model = model
        self.cordinator = cordinator
        records = model.recordsSubject
        playedItemProgress = recordPlayer.playerProgress
        isPlayed = recordPlayer.isPlaying
    }

    func addNewRecord() {
        cordinator.openAddNewRecordController()
    }

    func playItem(at row: Int) {
        if row == lastPlayedRow && isPlayed.value == true {
            recordPlayer.stop()
        } else {
            lastPlayedRow = row
            let fileName = records.value[row].fileName
            recordPlayer.play(fileName: fileName)
        }
    }

    func deleteItem(at row: Int) {
        if row == lastPlayedRow && isPlayed.value == true {
            recordPlayer.stop()
            lastPlayedRow = nil
        }

        model.deleteItem(at: row)

        if let lastPlayedRow = lastPlayedRow, row < lastPlayedRow {
            self.lastPlayedRow = lastPlayedRow - 1
        }
    }
}
