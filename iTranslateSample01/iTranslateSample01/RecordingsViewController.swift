//
//  RecordingsViewController.swift
//  iTranslateSample01
//
//  Created by Tarun Mukesh Kinger on 29/02/20.
//  Copyright © 2020 iTranslate. All rights reserved.
//

import UIKit
import AVKit

class RecordingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate {
    
    @IBOutlet weak var recordingsTableView: UITableView?
    var recordingsListModel = RecordingsListViewModel()
    
    var previousAudioSelectedIndexPath: IndexPath!
    var audioPlayer: AVAudioPlayer?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDataSource()

        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        RecorderUtility.animateTable(recordingsTableView)
    }
        
    func loadDataSource() {
        self.recordingsListModel.createRecordingsViewModel()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recordingsListModel.recordingsViewModels?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "RecordingsTableViewCell", for: indexPath) as? RecordingsTableViewCell, let recordsModel = self.recordingsListModel.recordingsViewModels?[indexPath.row] {
            // Configure the cell...
            cell.setRecordingData(recordsModel)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let previousIndexPath = previousAudioSelectedIndexPath, indexPath != previousAudioSelectedIndexPath, let cell = tableView.cellForRow(at: previousIndexPath) as? RecordingsTableViewCell {
            cell.progressViewWidth.constant = 0
        }
        if let cell = tableView.cellForRow(at: indexPath) as? RecordingsTableViewCell, let recordsModel = self.recordingsListModel.recordingsViewModels?[indexPath.row] {
            if indexPath == previousAudioSelectedIndexPath {
                cell.layer.removeAllAnimations()
                cell.progressViewWidth.constant = 0
            }
            cell.startProgress(recordsModel)
            playSound(index: indexPath.row)
            previousAudioSelectedIndexPath = indexPath
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection
                            section: Int) -> String? {
        return self.recordingsListModel.recordingsViewModels?.count ?? 0 > 0 ? "RECENTLY USED" : "No Recordings available"
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

            let action =  UIContextualAction(style: .normal, title: nil, handler: { (action,view,completionHandler ) in
                //do stuff
                let recordingModel = self.recordingsListModel.recordingsViewModels?[indexPath.row]
                if self.recordingsListModel.removeRecording(recordingModel) {
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.endUpdates()
                }
                tableView.reloadData()
                completionHandler(true)
            })
        action.image = UIImage(named: "DeleteButton")
        action.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [action])

        return configuration
    }
    
    @IBAction func doneButtonAction(_ sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func playSound(index: Int) {
        
        if audioPlayer != nil, (audioPlayer?.isPlaying)! {
            audioPlayer?.pause()
            audioPlayer = nil
        }
        
        if let recordModel = self.recordingsListModel.recordingsViewModels?[index], let fileName = recordModel.recordingName {
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
