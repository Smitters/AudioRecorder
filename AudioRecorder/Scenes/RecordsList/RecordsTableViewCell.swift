//
//  RecordsTableViewCell.swift
//  AudioRecorder
//
//  Created by Smetankin Dmitry on 6/22/19.
//  Copyright © 2019 Smetankin. All rights reserved.
//

import UIKit
import RxSwift

class RecordsTableViewCell: UITableViewCell {

    private let disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()

        playButton.rx.tap.throttle(.milliseconds(250), scheduler: MainScheduler.instance).bind { [weak self] in
            self?.playTapped?()
        }.disposed(by: disposeBag)

        deleteButton.rx.tap.throttle(.milliseconds(500), scheduler: MainScheduler.instance).bind { [weak self] in
            self?.deleteTapped?()
        }.disposed(by: disposeBag)
    }

    @IBOutlet weak var recordNameLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!

    var playTapped: (() -> Void)?
    var deleteTapped: (() -> Void)?
}
