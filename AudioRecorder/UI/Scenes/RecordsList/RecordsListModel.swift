//
//  RecordListModel.swift
//  AudioRecorder
//
//  Created by Smetankin Dmitry on 6/20/19.
//  Copyright © 2019 Smetankin. All rights reserved.
//

import Foundation

class RecordsListModel {

    private let persistence: PersistenceType

    init(persistence: PersistenceType) {
        self.persistence = persistence
    }
}
