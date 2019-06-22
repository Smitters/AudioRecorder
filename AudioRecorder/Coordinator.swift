//
//  Coordinator.swift
//  AudioRecorder
//
//  Created by Smetankin Dmitry on 6/20/19.
//  Copyright © 2019 Smetankin. All rights reserved.
//

import UIKit

protocol CoordinatorType {
    func start()
    func handleAppTerminate()
    func openAddNewRecordController()
}

class Coordinator: CoordinatorType {

    private lazy var persistence: Persistence = Persistence()

    private let window: UIWindow?
    private let navigationController: UINavigationController?

    init(window: UIWindow?) {
        self.window = window
        self.navigationController = window?.rootViewController as? UINavigationController
    }

    func start() {
        if let recordListViewController = navigationController?.children.first as? RecordsListViewController {
            let model = RecordsListModel(persistence: persistence)
            let viewModel = RecordsListViewModel(model: model, cordinator: self)

            recordListViewController.viewModel = viewModel
        }
    }

    func handleAppTerminate() {
        persistence.saveChanges()
    }

    func openAddNewRecordController() {
        let addNewViewController = Storyboards.CreateAudioRecorder.createAudioRecordViewController()
        let model = try! CreateAudioRecordModel(persistence: persistence)
        let viewModel = CreateAudioRecordViewModel(model: model, cordinator: self)
        addNewViewController.viewModel = viewModel

        let sender = navigationController?.topViewController
        sender?.present(addNewViewController, animated: true)
    }
}
