//
//  RecordingsTableViewCell.swift
//  iTranslateSample01
//
//  Created by Tarun Mukesh Kinger on 29/02/20.
//  Copyright © 2020 iTranslate. All rights reserved.
//

import UIKit

class RecordingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var recordingNumberLabel: UILabel!
    @IBOutlet weak var recordingTimeButton: UIButton!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var progressViewWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func setRecordingData(_ recordsModel: RecordingsViewModel) {
        self.recordingNumberLabel?.text = recordsModel.recordingName
        self.recordingTimeButton?.setTitle(recordsModel.trackTime, for: .normal)
    }
    
    func startProgress(_ recordsModel: RecordingsViewModel) {
        self.layoutIfNeeded()
        self.layer.removeAllAnimations()
        self.progressViewWidth.constant = self.contentView.frame.size.width
        UIView.animate(withDuration: TimeInterval(recordsModel.trackDurationInSeconds), animations: {
            self.layoutIfNeeded()
        }, completion: {_ in
            self.progressViewWidth.constant = 0
            self.setSelected(false, animated: false)
        })
    }
}
