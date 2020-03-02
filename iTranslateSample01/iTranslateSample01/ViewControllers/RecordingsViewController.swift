//
//  RecordingsViewController.swift
//  iTranslateSample01
//
//  Created by Tarun Mukesh Kinger on 29/02/20.
//  Copyright © 2020 iTranslate. All rights reserved.
//

import UIKit
import AVKit

/// RecordingsViewController viewcontroller class that displays the table of recorded audio data
class RecordingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate {
    
    /// The UITableView used to display the list of recording models
    @IBOutlet weak var recordingsTableView: UITableView?
    
    /// RecordingsListViewModel viewModel object that stores the data pertaining to the recorded audio
    var recordingsListModel = RecordingsListViewModel()
    
    /// the indexPath of the previously selected cell to stop animations on the previous cell
    var previousAudioSelectedIndexPath: IndexPath!
    
    /// AVAudioPlayer instance to play the contents of the audio file when the cell is tapped
    var audioPlayer: AVAudioPlayer?

    /// Override of the viewDidLoad delegate method to customize our view's behaviour
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.recordingsTableView?.isAccessibilityElement = false

        loadDataSource()
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    /// Override of the viewWillAppear delegate method to customize our view's behaviour
    override func viewWillAppear(_ animated: Bool) {
        RecorderUtility.animateTable(recordingsTableView)
    }
    
    /// Method that creates and loads the RecordingsListViewModel viewModel
    func loadDataSource() {
        self.recordingsListModel.createRecordingsViewModel()
    }
    
    /// TableView delegate to calculate the number of rows to be displayed in each section
    /// - Parameters:
    ///   - tableView: UITableView instance
    ///   - section: the current section for which the number of rows need to be calculated
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recordingsListModel.recordingsViewModelsArray?.count ?? 0
    }
    
    /// TableView delegate to configure the cell and display a custom UITableViewCell
    /// - Parameters:
    ///   - tableView: UITableView instance
    ///   - indexPath: indexPath of the current cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: kRecordingsCellIdentifier, for: indexPath) as? RecordingsTableViewCell, let recordsModel = self.recordingsListModel.recordingsViewModelsArray?[indexPath.row] {
            // Configure the cell...
            cell.setRecordingData(recordsModel)
            return cell
        }
        return UITableViewCell()
    }
    
    /// TableView delegate to configure the cell and display the behaviour when tapping on the UITableViewCell
    /// - Parameters:
    ///   - tableView: UITableView instance
    ///   - indexPath: indexPath of the current cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let previousIndexPath = previousAudioSelectedIndexPath, indexPath != previousAudioSelectedIndexPath, let cell = tableView.cellForRow(at: previousIndexPath) as? RecordingsTableViewCell {
            cell.progressViewWidth.constant = 0
        }
        if let cell = tableView.cellForRow(at: indexPath) as? RecordingsTableViewCell, let recordsModel = self.recordingsListModel.recordingsViewModelsArray?[indexPath.row] {
            if indexPath == previousAudioSelectedIndexPath {
                cell.layer.removeAllAnimations()
                cell.progressViewWidth.constant = 0
            }
            cell.startProgress(recordsModel)
            playSound(index: indexPath.row)
            previousAudioSelectedIndexPath = indexPath
        }
    }
    
    /// TableView delegate to decide the section header title for each section
    /// - Parameters:
    ///   - tableView: UITableView instance
    ///   - section: section of the current cell
    func tableView(_ tableView: UITableView, titleForHeaderInSection
                            section: Int) -> String? {
        return self.recordingsListModel.recordingsViewModelsArray?.count ?? 0 > 0 ? kRecentlyUsed : kNoRecordingsAvailable
    }
    
    /// TableView delegate to ascertain whether the user can swipe to use the tableView's editing mode
    /// - Parameters:
    ///   - tableView: UITableView instance
    ///   - indexPath: indexPath of the current cell
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /// Method to configure the UI of the view displayed on the trailing swipe action
    /// - Parameters:
    ///   - tableView: UITableView instance
    ///   - indexPath: indexPath of the current cell
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

            let action =  UIContextualAction(style: .normal, title: nil, handler: { (action,view,completionHandler ) in
                //do stuff
                let recordingModel = self.recordingsListModel.recordingsViewModelsArray?[indexPath.row]
                if self.recordingsListModel.removeRecording(recordingModel) {
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.endUpdates()
                }
                tableView.reloadData()
                completionHandler(true)
            })
        
        // Custom delete button for swipe left action
        action.image = UIImage(named: kDeleteButtonImageName)
        action.backgroundColor = .red
        action.isAccessibilityElement = true
        action.accessibilityValue = "deleteButton"
        let configuration = UISwipeActionsConfiguration(actions: [action])

        return configuration
    }
    
    /// The IBAction initiated when the user taps on the Done bar button
    /// - Parameter sender: UIButton instance which initiated this action
    @IBAction func doneButtonAction(_ sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    /// The method that initiates/stops the AVAudioPlayer instance to play the audio
    /// - Parameter index: index value to fetch the data from the view model
    func playSound(index: Int) {
        
        if audioPlayer != nil, (audioPlayer?.isPlaying)! {
            audioPlayer?.stop()
            audioPlayer = nil
        }
        
        if let recordModel = self.recordingsListModel.recordingsViewModelsArray?[index], let fileName = recordModel.recordingName {
            let audioFilename = RecorderUtility.getDocumentsDirectory()?.appendingPathComponent("\(fileName).caf")
            guard let url = audioFilename else { return }
            
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                
                guard let player = audioPlayer else { return }
                
                player.prepareToPlay()
                player.play()
                player.delegate = self
                
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }

}
