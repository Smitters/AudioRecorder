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
    @IBOutlet private weak var closeButton: UIButton!

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

        setupBindings()
    }

    private func setupBindings() {
        guard let viewModel = viewModel else { return }

        viewModel.recordDuration.asDriver(onErrorJustReturn: "0.00").drive(timeLabel.rx.text).disposed(by: disposeBag)

        recordButton.rx.tap.bind { [weak viewModel] in
            viewModel?.toggleRecord()
        }.disposed(by: disposeBag)

        closeButton.rx.tap.bind { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
    }
}
