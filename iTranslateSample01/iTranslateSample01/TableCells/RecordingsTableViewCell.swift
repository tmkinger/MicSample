//
//  RecordingsTableViewCell.swift
//  iTranslateSample01
//
//  Created by Tarun Mukesh Kinger on 29/02/20.
//  Copyright © 2020 iTranslate. All rights reserved.
//

import UIKit

/// RecordingsTableViewCell class to handle the behaviour of the table cell that displays the recorded audio data
class RecordingsTableViewCell: UITableViewCell {
    
    /// the label that displays the name of the audio file, without extension
    @IBOutlet weak var recordingNumberLabel: UILabel!
    
    /// The UILabel that displays the duration of the audio track
    @IBOutlet weak var recordingTimeLabel: UILabel!
    
    /// A UIView in the background that can be used to display the progress of the audio track while playing it
    @IBOutlet weak var progressView: UIView!
    
    /// An NSLayoutConstraint value to change the width of the progress view
    @IBOutlet weak var progressViewWidth: NSLayoutConstraint!
    
    /// Override of the awakeFromNib method of the cell
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.isAccessibilityElement = false
        self.contentView.isAccessibilityElement = false
    }
    
    /// Method to populate the data for the cell from the RecordingsViewModel object
    /// - Parameter recordsModel: RecordingsViewModel object
    public func setRecordingData(_ recordsModel: RecordingsViewModel) {
        self.recordingNumberLabel?.text = recordsModel.recordingName
        self.recordingTimeLabel?.text = recordsModel.trackTime
    }
    
    /// Method to start animating the progress view using the width constraint
    /// - Parameter recordsModel: RecordingsViewModel object
    func startProgress(_ recordsModel: RecordingsViewModel) {
        self.setSelected(false, animated: false)
        self.layoutIfNeeded()
        self.layer.removeAllAnimations()
        self.progressViewWidth.constant = 0
        self.progressViewWidth.constant = self.contentView.frame.size.width
        UIView.animate(withDuration: TimeInterval(recordsModel.trackDurationInSeconds), animations: {
            self.layoutIfNeeded()
        }, completion: {_ in
            self.progressViewWidth.constant = 0
            if self.isSelected {
                self.setSelected(false, animated: false)
            }
        })
    }
}
