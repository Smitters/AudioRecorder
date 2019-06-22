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
            let url = records.value[row].fileUrl
            recordPlayer.play(url: url)
        }
    }
}
