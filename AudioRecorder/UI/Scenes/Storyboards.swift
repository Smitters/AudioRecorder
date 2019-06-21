//
//  Storyboards.swift
//  AudioRecorder
//
//  Created by Smetankin Dmitry on 6/20/19.
//  Copyright © 2019 Smetankin. All rights reserved.
//

import UIKit

enum Storyboards {
    enum RecordList {
        private static let recordListStoryboard = UIStoryboard(name: "RecordsList", bundle: Bundle.main)

        static func recordsListViewController() -> RecordsListViewController {
            return recordListStoryboard.instantiateViewController()
        }
    }

    enum CreateAudioRecorder {
        private static let createAudioRecordStoryboard = UIStoryboard(name: "CreateAudioRecord", bundle: Bundle.main)

        static func createAudioRecordViewController() -> CreateAudioRecordViewController {
            return createAudioRecordStoryboard.instantiateViewController()
        }
    }
}

extension UIStoryboard {
    func instantiateViewController<T>() -> T {
        guard let controller = self.instantiateViewController(withIdentifier: String(describing: T.self)) as? T else {
            fatalError("Cannot instantiate \(T.self). Do you add storyboardID?")
        }

        return controller
    }
}
