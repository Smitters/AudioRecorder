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

        viewModel.records.bind(to: tableView.rx.items(cellIdentifier: String(describing: RecordsTableViewCell.self))) { [weak self] (row, element, cell) in

            guard let self = self, let viewModel = self.viewModel else { return }

            if let cell = cell as? RecordsTableViewCell {
                cell.recordNameLabel.text = element.name
                cell.durationLabel.text = "\(Int(element.duration.rounded(.up))) sec"

                if row == viewModel.lastPlayedRow && viewModel.isPlayed.value {
                    cell.playButton.setImage(UIImage(imageLiteralResourceName: "stop"), for: .normal)
                    cell.progressView.progress = viewModel.playedItemProgress.value
                } else {
                    cell.playButton.setImage(UIImage(imageLiteralResourceName: "play"), for: .normal)
                    cell.progressView.progress = 0
                }

                cell.playTapped = { [weak self] in
                    self?.viewModel?.playItem(at: row)
                }

                cell.deleteTapped = { [weak self] in
                    self?.viewModel?.deleteItem(at: row)
                }
            }
        }.disposed(by: disposeBag)

        viewModel.isPlayed.asDriver().drive(onNext: { [weak self] isPlayed in
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)

        viewModel.playedItemProgress.asDriver().drive(onNext: { [weak self] progress in
            guard let self = self, let row = self.viewModel?.lastPlayedRow,
                  let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? RecordsTableViewCell else {
                    return
            }

            cell.progressView.progress = viewModel.playedItemProgress.value
        }).disposed(by: disposeBag)

        tableView.rx.itemSelected.bind { [weak self] path in
            self?.viewModel?.selectItem(at: path.row)
        }.disposed(by: disposeBag)

        addButton.rx.tap.bind { [weak viewModel] in
            viewModel?.addNewRecord()
        }.disposed(by: disposeBag)
    }
}
