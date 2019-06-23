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

    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var waveView: WaveView!

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

        viewModel.waveViewWidth.asDriver().drive(onNext: { [weak self] width in
            self?.widthConstraint.constant = width
            self?.view.layoutIfNeeded()
        }).disposed(by: disposeBag)

        viewModel.createWavePoints()
    }
}
