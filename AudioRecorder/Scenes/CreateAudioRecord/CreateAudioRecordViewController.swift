//
//  CreateAudioRecordViewController.swift
//  AudioRecorder
//
//  Created by Smetankin Dmitry on 6/20/19.
//  Copyright © 2019 Smetankin. All rights reserved.
//

import UIKit
import RxSwift

class CreateAudioRecordViewController: UIViewController {

    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var recordButton: UIButton!
    @IBOutlet private weak var cancelButton: UIBarButtonItem!
    @IBOutlet private weak var navigationBar: UINavigationBar!

    private let disposeBag = DisposeBag()

    var viewModel: CreateAudioRecordViewModel? {
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

        viewModel.recordDuration.asDriver(onErrorJustReturn: "00.00").drive(timeLabel.rx.text).disposed(by: disposeBag)

        recordButton.rx.tap.throttle(.seconds(1), scheduler: MainScheduler.instance).bind { [weak viewModel] in
            viewModel?.toggleRecord()
        }.disposed(by: disposeBag)

        cancelButton.rx.tap.bind { [weak viewModel] in
            viewModel?.cancel()
        }.disposed(by: disposeBag)
    }

    private func setupUI() {
        navigationBar.delegate = self
    }
}

extension CreateAudioRecordViewController: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}