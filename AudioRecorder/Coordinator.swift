//
//  Coordinator.swift
//  AudioRecorder
//
//  Created by Smetankin Dmitry on 6/20/19.
//  Copyright © 2019 Smetankin. All rights reserved.
//

import UIKit

protocol AppCoordinatorType {
    func startApplication()
    func handleAppTerminate()
}

protocol RecordListCoordinatorType {
    func openAddNewRecordController()
    func showDetails(for record: AudioRecord)
}

protocol CreateAudioCoordinatorType {
    func dismiss()
    func showError(_ error: Error, completion: (() -> Void)?)
}

protocol RecordDetailsCoordinatorType {
    func goBack()
}

class Coordinator {

    private lazy var persistence: Persistence = Persistence()

    private let window: UIWindow?
    private let navigationController: UINavigationController?

    private var topViewController: UIViewController? {
        if let presented = navigationController?.presentedViewController {
            return presented
        } else {
            return navigationController?.topViewController
        }
    }

    init(window: UIWindow?) {
        self.window = window
        self.navigationController = window?.rootViewController as? UINavigationController
    }
}

extension Coordinator: AppCoordinatorType {
    func startApplication() {
        if let recordListViewController = navigationController?.children.first as? RecordsListViewController {
            let model = RecordsListModel(persistence: persistence)
            let viewModel = RecordsListViewModel(model: model, cordinator: self)

            recordListViewController.viewModel = viewModel
        }
    }

    func handleAppTerminate() {
        persistence.saveChanges()
    }
}

extension Coordinator: RecordListCoordinatorType {
    func openAddNewRecordController() {
        let addNewViewController = Storyboards.CreateAudioRecorder.createAudioRecordViewController()
        let model = try! CreateAudioRecordModel(persistence: persistence)
        let viewModel = CreateAudioRecordViewModel(model: model, coordinator: self)
        addNewViewController.viewModel = viewModel

        topViewController?.present(addNewViewController, animated: true)
    }

    func showDetails(for record: AudioRecord) {
        let detailsController = Storyboards.RecordDetails.recordDetailsViewController()
        let viewModel = RecordDetailsViewModel(record: record, persistence: persistence, coordinator: self)
        detailsController.viewModel = viewModel

        navigationController?.pushViewController(detailsController, animated: true)
    }
}

extension Coordinator: CreateAudioCoordinatorType {
    func dismiss() {
        navigationController?.topViewController?.dismiss(animated: true)
    }

    func showError(_ error: Error, completion: (() -> Void)?) {
        let alertController = UIAlertController(title: "Ooops, error occured", message: error.localizedDescription, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))

        topViewController?.present(alertController, animated: true)
    }
}

extension Coordinator: RecordDetailsCoordinatorType {
    func goBack() {
        navigationController?.popViewController(animated: true)
    }
}
