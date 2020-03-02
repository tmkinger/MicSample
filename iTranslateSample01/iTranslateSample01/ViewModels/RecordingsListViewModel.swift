//
//  RecordingsListViewModel.swift
//  iTranslateSample01
//
//  Created by Tarun Mukesh Kinger on 29/02/20.
//  Copyright © 2020 iTranslate. All rights reserved.
//

import UIKit
import AVKit

/// RecordingsViewModel to store data pertaining to the audio file
class RecordingsViewModel: NSObject {
    
    /// Name of the audio file
    public var recordingName: String?
    
    /// the duration of the audio file as a formatted string
    public var trackTime: String?
    
    /// the duration of the audio file in seconds
    public var trackDurationInSeconds: Int
    
    /// Custom init method for the viewModel based on the file name
    /// - Parameter recordingName: file name of the audio file
    init(recordingName :String) {
        self.recordingName = recordingName
        self.trackDurationInSeconds = 0
    }
}

/// RecordingsListViewModel class to populate the viewModel for the records table view
class RecordingsListViewModel: NSObject {
    
    /// An array of RecordingsViewModel objects pertaining to the stored recorded audios
    private(set) var recordingsViewModelsArray :[RecordingsViewModel]? = [RecordingsViewModel]()
    
    /// Override init
    override init() {
        super.init()
    }
    
    /// Method to create the RecordingsViewModel viewModel
    func createRecordingsViewModel(){
        if let fileNameArray = RecorderUtility.fetchFileNames(), fileNameArray.count > 0 {
            for fileName in fileNameArray {
                let recordingListModel = RecordingsViewModel(recordingName: fileName)
                (recordingListModel.trackTime, recordingListModel.trackDurationInSeconds) = self.fetchTrackDuration(fileName: fileName)
                self.recordingsViewModelsArray?.append(recordingListModel)
            }
        }
    }
    
    /// Method to delete the recording model from the viewModel and the recorded file file from the device
    /// - Parameter recordingModel: RecordingsViewModel object
    func removeRecording(_ recordingModel: RecordingsViewModel?) -> Bool {
        if let fileName = recordingModel?.recordingName {
            if delete(fileName: fileName) {
                if let model = recordingModel, let index = self.recordingsViewModelsArray?.firstIndex(of: model) {
                    self.recordingsViewModelsArray?.remove(at: index)
                    return true
                }
            }
        }
        return false
    }

    
    /// Method to delete the audio file based on the file name
    /// - Parameter fileName: file name of the audio file
    func delete(fileName : String)->Bool{
        let fileManager = FileManager.default
        let docDir = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let filePath = docDir.appendingPathComponent(fileName).appendingPathExtension("caf")
        do {
            try fileManager.removeItem(at: filePath)
            return true
        }
        catch {
            print("Error")
        }
        return false
    }
    
    /// Method to format and form the track duration string to be displayed in the table cell
    /// - Parameter fileName: filename of the audio file
    func fetchTrackDuration(fileName: String?) -> (String?, Int) {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let url = NSURL(fileURLWithPath: path)
        if let filename = fileName, let pathComponent = url.appendingPathComponent(filename)?.appendingPathExtension("caf") {
                let filePath = pathComponent.path
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: filePath) {
                    let audioAsset = AVAsset(url: URL(fileURLWithPath: filePath))
                    let duration = audioAsset.duration
                    let (h,m,s) = secondsToHoursMinutesSeconds(seconds: Int(CMTimeGetSeconds(duration)))
                    return (formattedTrackDuration(hours: h, mins: m, secs: s), Int(duration.seconds))
                } else {
                    print("FILE NOT AVAILABLE")
                }
            } else {
                print("FILE PATH NOT AVAILABLE")
            }

        return ("",0)
    }
    
    /// Method to format the track's duration based on input in hours, minutes and seconds
    /// - Parameters:
    ///   - hours: hours value
    ///   - mins: minutes value
    ///   - secs: seconds value
    func formattedTrackDuration(hours:Int, mins: Int, secs: Int) -> String? {
        var trackDuration = ""
        
        if hours > 0 {
            trackDuration.append(String(format:"%02i:", hours))
        }
        
        if mins > 0 {
            trackDuration.append(String(format:"%02i:", mins))
        } else {
            trackDuration.append("00:")
        }
        
        if secs > 0 {
            trackDuration.append(String(format:"%02i", secs))
        } else {
            trackDuration.append("00")
        }
        
        return trackDuration
    }
    
    /// Method to convert the seconds into hours, minutes and seconds
    /// - Parameter seconds: int representation of the number of seconds
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }

}
