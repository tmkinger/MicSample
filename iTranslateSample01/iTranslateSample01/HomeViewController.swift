//
//  HomeViewController.swift
//  iTranslateSample01
//
//  Created by Tarun Mukesh Kinger on 29/02/20.
//  Copyright © 2020 iTranslate. All rights reserved.
//

import UIKit
import AVKit
import QuartzCore

/// HomeViewController class defines the initial view controller that presents the user with the option to record audio or view their recordings
class HomeViewController: UIViewController, AVAudioRecorderDelegate {
    
    /// The mic button used for recording audio
    @IBOutlet weak var micButton: UIButton!
    
    /// The button that allows the user to view their recordings
    @IBOutlet weak var showRecordingsButton: UIButton!
    
    /// A custom view displayed to the user if they haven't granted mic permission
    @IBOutlet weak var micPermissionView: UIView!
    
    /// An AVAudioSession instance to record  the user's audio
    var recordingSession: AVAudioSession!
    
    /// The recorder object used to record and save the user's audio
    var audioRecorder: AVAudioRecorder!
    
    
    /// Override of the viewDidLoad delegate method to customize our view's behaviour
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.micPermissionView.isHidden = true
        
        recordingSession = AVAudioSession.sharedInstance()
        checkMicPermissionStatus()
    }
    
    /// This method checks the mic permission status and handles the behaviour for the different states
    func checkMicPermissionStatus() {
        let status = AVAudioSession.sharedInstance().recordPermission
            switch (status)
            {
            case .granted:
                // Set the recordingSession properties if the permission is granted
                do {
                    try recordingSession.setCategory(.playAndRecord, mode: .default)
                    try recordingSession.setActive(true)

                } catch {
                    // failed to record!
                }
                
            case .undetermined:
                // Display the mic permission view if the permission is not determined
                micPermissionView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {() -> Void in
                    self.view.backgroundColor = UIColor.init(red: 20/255, green: 34/255, blue: 43/255, alpha: 0.3)
                    self.micPermissionView.isHidden = false
                    self.micPermissionView.transform = .identity
                }, completion: {(finished: Bool) -> Void in
                    // do something once the animation finishes, put it here
                })

            case .denied:
                // Display an alert to the user if the mic permission is denied
                self.displayMicPermissionDeniedAlert()
                
            @unknown default:
                print("Permission Error")
        }
    }
    
    /// Method to display the mic permission denied alert to the user ; Tapping on Go to Settings allows the user to give the permission from the Settings
    func displayMicPermissionDeniedAlert()
    {
        DispatchQueue.main.async
            {
                var alertText = "Permission Error"
                var alertButton = "OK"
                var goAction = UIAlertAction(title: alertButton, style: .default, handler: nil)
                
                if UIApplication.shared.canOpenURL(URL(string: UIApplication.openSettingsURLString)!)
                {
                    alertText = "It looks like your privacy settings are preventing us from accessing your microphone to record audio. You can fix this by doing the following:\n\n1. Touch the Go button below to open the Settings app.\n\n2. Turn the Mic on.\n\n3. Open this app and try again."
                    
                    alertButton = "Go to Settings"
                    
                    goAction = UIAlertAction(title: alertButton, style: .default, handler: {(alert: UIAlertAction!) -> Void in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    })
                }
                
                let alert = UIAlertController(title: "Permission Error", message: alertText, preferredStyle: .alert)
                alert.addAction(goAction)
                self.present(alert, animated: true, completion: nil)
        }
    }
    
    /// The IBAction method called when tapping on the mic button; tapping on this allows the user to record their audio
    /// - Parameter sender: UIButton instance which initiated this action
    @IBAction func micButtonAction(_ sender: UIButton) {
        if audioRecorder == nil {
            startRecording()
            self.micButton.blink()
        } else {
            self.micButton.blink(enabled: false)
            finishRecording(success: true)
        }
    }
    
    /// The IBAction methd called when  the user taps on the Allow button in the mic permission view
    /// - Parameter sender: UIButton instance which initiated this action
    @IBAction func allowMicAccessAction(_ sender: UIButton) {
        
        recordingSession.requestRecordPermission() { [unowned self] allowed in
            DispatchQueue.main.async {
                if allowed {
                    self.maybeLaterAction(sender)
                } else {
                    // failed to record!
                    self.displayMicPermissionDeniedAlert()
                }

            }
        }
        
    }
    
    /// The IBAction method called when the user taps on the Maybe Later button in the mic permission view
    /// - Parameter sender: UIButton instance which initiated this action
    @IBAction func maybeLaterAction(_ sender: UIButton) {
        micPermissionView.transform = .identity
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {() -> Void in
            self.view.backgroundColor = UIColor.white
            self.micPermissionView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }, completion: {(finished: Bool) -> Void in
            // do something once the animation finishes, put it here
            self.micPermissionView.isHidden = true
        })
    }
    
    /// This method sets the settings for the audio recorder and begins recording audio to the caf file in the Documents directory
    func startRecording() {
        if AVAudioSession.sharedInstance().recordPermission == .granted {
            let newFileNumber = RecorderUtility.getLastFileIndex() + 1
            if let audioFilename = RecorderUtility.getDocumentsDirectory()?.appendingPathComponent("Record \(newFileNumber).caf") {
                
                let settings = [
                    AVSampleRateKey: 44100,
                    AVEncoderBitRateKey: 16,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]
                
                do {
                    audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                    audioRecorder.delegate = self
                    
                    audioRecorder.record()
                } catch {
                    finishRecording(success: false)
                }
            }
        } else {
            self.checkMicPermissionStatus()
        }
    }
    
    /// Method that completes the audio recording and displays an alert to the user
    /// - Parameter success: a Bool var to indicate the success state to the user
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil

        if success {
            let alert = UIAlertController.init(title: "Saved", message: "Recording Saved!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    /// Delegate method called when the audio recorder finished recording
    /// - Parameters:
    ///   - recorder: the AVAudioRecorder instance
    ///   - flag: Bool var to indicate success status
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }

    
    // MARK: - Navigation

//     In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//         Get the new view controller using segue.destination.
//         Pass the selected object to the new view controller.
        if audioRecorder != nil {
            self.micButton.blink(enabled: false)
            finishRecording(success: false)
        }
    }
    
}
