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

        viewModel.isRecording.asDriver().drive(onNext: { [weak self] isRecording in
            guard let self = self else { return }
            UIView.transition(with: self.recordButton, duration: 0.3, options: .transitionFlipFromTop, animations: {
                if isRecording {
                    self.recordButton.setImage(UIImage(imageLiteralResourceName: "stop"), for: .normal)
                    self.recordButton.tintColor = .red
                } else {
                    self.recordButton.setImage(UIImage(imageLiteralResourceName: "mic"), for: .normal)
                    self.recordButton.tintColor = .black
                }
            })
        }).disposed(by: disposeBag)
    }

    private func setupUI() {
        navigationBar.delegate = self
        recordButton.layer.cornerRadius = recordButton.bounds.height / 2
        recordButton.layer.borderWidth = 2
        recordButton.layer.borderColor = UIColor.black.cgColor
    }
}

extension CreateAudioRecordViewController: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
