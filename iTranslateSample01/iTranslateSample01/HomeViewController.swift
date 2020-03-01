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

class HomeViewController: UIViewController, AVAudioRecorderDelegate {
    
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var showRecordingsButton: UIButton!
    @IBOutlet weak var micPermissionView: UIView!

    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var player: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.micPermissionView.isHidden = true
        
        recordingSession = AVAudioSession.sharedInstance()
        checkMicPermissionStatus()
    }
    
    func checkMicPermissionStatus() {
        let status = AVAudioSession.sharedInstance().recordPermission
            switch (status)
            {
            case .granted:
                do {
                    try recordingSession.setCategory(.playAndRecord, mode: .default)
                    try recordingSession.setActive(true)

                } catch {
                    // failed to record!
                }
            case .undetermined:
                micPermissionView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {() -> Void in
                    self.view.backgroundColor = UIColor.init(red: 20/255, green: 34/255, blue: 43/255, alpha: 0.3)
                    self.micPermissionView.isHidden = false
                    self.micPermissionView.transform = .identity
                }, completion: {(finished: Bool) -> Void in
                    // do something once the animation finishes, put it here
                })

            case .denied:
                self.micDenied()
            @unknown default:
                print("Error")
        }
    }
    
    func micDenied()
    {
        DispatchQueue.main.async
            {
                var alertText = ""
                var alertButton = ""
                var goAction = UIAlertAction(title: alertButton, style: .default, handler: nil)

                if UIApplication.shared.canOpenURL(URL(string: UIApplication.openSettingsURLString)!)
                {
                    alertText = "It looks like your privacy settings are preventing us from accessing your microphone to record audio. You can fix this by doing the following:\n\n1. Touch the Go button below to open the Settings app.\n\n2. Turn the Mic on.\n\n3. Open this app and try again."

                    alertButton = "Go"

                    goAction = UIAlertAction(title: alertButton, style: .default, handler: {(alert: UIAlertAction!) -> Void in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    })
                }

                let alert = UIAlertController(title: "Permission Error", message: alertText, preferredStyle: .alert)
                alert.addAction(goAction)
                self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func micButtonAction(_ sender: UIButton) {
        if audioRecorder == nil {
            startRecording()
            self.micButton.blink()
        } else {
            self.micButton.blink(enabled: false)
            finishRecording(success: true)
        }
    }
    
    @IBAction func allowMicAccessAction(_ sender: UIButton) {
        
        recordingSession.requestRecordPermission() { [unowned self] allowed in
            DispatchQueue.main.async {
                if allowed {
                    self.maybeLaterAction(sender)
                } else {
                    // failed to record!
                    self.micDenied()
                }

            }
        }
        
    }
    
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
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil

        if success {
            let alert = UIAlertController.init(title: "Saved", message: "Recording Saved!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else {
            // recording failed :(
        }
    }
    
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
