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

class RecordsListViewController: UITableViewController {

    @IBOutlet private weak var addButton: UIBarButtonItem!

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
    }
}
