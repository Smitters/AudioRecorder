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
    private let cordinator: RecordListCoordinatorType
    private let disposeBag = DisposeBag()
    private let recordPlayer = RecordPlayer()

    let records: BehaviorRelay<[AudioRecord]>
    let playedItemProgress: BehaviorRelay<Float>
    let isPlaying: BehaviorRelay<Bool>

    var currentlyPlayedRow: Int?

    init(model: RecordsListModel, cordinator: RecordListCoordinatorType) {
        self.model = model
        self.cordinator = cordinator
        records = model.recordsSubject
        playedItemProgress = recordPlayer.playerProgress
        isPlaying = recordPlayer.isPlaying
    }

    func addNewRecord() {
        cordinator.openAddNewRecordController()
    }

    func playItem(at row: Int) {
        if row == currentlyPlayedRow && isPlaying.value == true {
            recordPlayer.stop()
            currentlyPlayedRow = nil
        } else {
            currentlyPlayedRow = row
            let fileName = records.value[row].fileName
            recordPlayer.play(fileName: fileName)
        }
    }

    func selectItem(at row: Int) {
        recordPlayer.stop()
        currentlyPlayedRow = nil
        cordinator.showDetails(for: records.value[row])
    }

    func deleteItem(at row: Int) {
        if row == currentlyPlayedRow && isPlaying.value == true {
            recordPlayer.stop()
            currentlyPlayedRow = nil
        }

        model.deleteItem(at: row)

        if let playedRow = currentlyPlayedRow, row < playedRow {
            self.currentlyPlayedRow = playedRow - 1
        }
    }
}
