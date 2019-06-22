//
//  ViewController.swift
//  AudioRecorder
//
//  Created by Smetankin Dmitry on 6/20/19.
//  Copyright © 2019 Smetankin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RecordsListViewController: UIViewController {

    @IBOutlet private weak var addButton: UIBarButtonItem!
    @IBOutlet private weak var tableView: UITableView!

    private let disposeBag = DisposeBag()

    var viewModel: RecordsListViewModel? {
        didSet {
            if isViewLoaded {
                setupBindings()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBindings()
    }

    private func setupBindings() {
        guard let viewModel = viewModel else { return }

        addButton.rx.tap.bind { [weak viewModel] in
            viewModel?.addNewRecord()
        }.disposed(by: disposeBag)

        viewModel.records.bind(to: tableView.rx.items(cellIdentifier: String(describing: RecordsTableViewCell.self))) { (row, element, cell) in

            if let cell = cell as? RecordsTableViewCell {
                cell.recordNameLabel.text = element.name
                cell.durationLabel.text = "\(Int(element.duration.rounded(.up))) sec"
                cell.progressView.progress = 0
            }

        }.disposed(by: disposeBag)
    }
}
