//
//  RecordDetailsViewController.swift
//  AudioRecorder
//
//  Created by Smetankin Dmitry on 6/22/19.
//  Copyright © 2019 Smetankin. All rights reserved.
//

import UIKit
import AVFoundation
import RxSwift

class RecordDetailsViewController: UIViewController {

    @IBOutlet weak var waveView: WaveView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!

    let disposeBag = DisposeBag()

    var viewModel: RecordDetailsViewModel? {
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

        viewModel.wavePoints.asDriver().drive(onNext: { [weak self] points in
            self?.waveView.wavePoints = points
        }).disposed(by: disposeBag)

        viewModel.playerProgress.asDriver().drive(onNext: { [weak self] progress in
            self?.waveView.progress = progress
        }).disposed(by: disposeBag)

        viewModel.durationText.asDriver(onErrorJustReturn: "00.00 | 00.00").drive(durationLabel.rx.text).disposed(by: disposeBag)

        playButton.rx.tap.throttle(.milliseconds(350), scheduler: MainScheduler.instance).bind { [weak viewModel] in
            viewModel?.toggleStart()
        }.disposed(by: disposeBag)

        viewModel.isPlaying.asDriver().drive(onNext: { [weak self] isPlaying in
            guard let self = self else { return }
            UIView.transition(with: self.playButton, duration: 0.3, options: .transitionFlipFromBottom, animations: {
                if isPlaying {
                    self.playButton.setImage(UIImage(imageLiteralResourceName: "stop"), for: .normal)
                } else {
                    self.playButton.setImage(UIImage(imageLiteralResourceName: "play"), for: .normal)
                }
            })
        }).disposed(by: disposeBag)

        fileNameLabel.text = viewModel.name
        viewModel.createWavePoints()
    }
}
