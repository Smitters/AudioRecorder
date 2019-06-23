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

        setupUI()
        setupBindings()
    }

    private func setupBindings() {
        guard let viewModel = viewModel else { return }

        viewModel.records.bind(to: tableView.rx.items(cellIdentifier: String(describing: RecordsTableViewCell.self))) { [weak self] (row, element, cell) in

            guard let self = self, let viewModel = self.viewModel else { return }

            if let cell = cell as? RecordsTableViewCell {
                cell.recordNameLabel.text = element.name
                cell.durationLabel.text = "\(element.duration.timeString) sec"

                if row == viewModel.currentlyPlayedRow && viewModel.isPlaying.value {
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

        viewModel.isPlaying.asDriver().drive(onNext: { [weak self] isPlayed in
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)

        viewModel.playedItemProgress.asDriver().drive(onNext: { [weak self] progress in
            guard let self = self, let row = self.viewModel?.currentlyPlayedRow,
                  let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? RecordsTableViewCell else {
                    return
            }

            let element = viewModel.item(at: row)
            let remainingDuration = element.duration * TimeInterval(1 - progress)
            cell.durationLabel.text = "\(remainingDuration.timeString) sec"
            cell.progressView.progress = viewModel.playedItemProgress.value
        }).disposed(by: disposeBag)

        tableView.rx.itemSelected.bind { [weak self] path in
            self?.viewModel?.selectItem(at: path.row)
        }.disposed(by: disposeBag)

        addButton.rx.tap.bind { [weak viewModel] in
            viewModel?.addNewRecord()
        }.disposed(by: disposeBag)
    }

    private func setupUI() {
        tableView.tableFooterView = UIView()
    }
}
