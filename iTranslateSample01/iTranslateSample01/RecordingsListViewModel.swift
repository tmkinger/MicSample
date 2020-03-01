//
//  RecordingsListViewModel.swift
//  iTranslateSample01
//
//  Created by Tarun Mukesh Kinger on 29/02/20.
//  Copyright © 2020 iTranslate. All rights reserved.
//

import UIKit
import AVKit

class RecordingsListViewModel: NSObject {
    
    private(set) var recordingsViewModels :[RecordingsViewModel]? = [RecordingsViewModel]()
    
    override init() {
        super.init()
    }
    
    func createRecordingsViewModel(){
        if let fileNameArray = RecorderUtility.fetchFileNames(), fileNameArray.count > 0 {
            for fileName in fileNameArray {
                let recordingListModel = RecordingsViewModel(recordingName: fileName)
                (recordingListModel.trackTime, recordingListModel.trackDurationInSeconds) = self.fetchTrackDuration(fileName: fileName)
                self.recordingsViewModels?.append(recordingListModel)
            }
        }
    }
    
    func removeRecording(_ recordingModel: RecordingsViewModel?) -> Bool {
        if let fileName = recordingModel?.recordingName {
            if delete(fileName: fileName) {
                if let model = recordingModel, let index = self.recordingsViewModels?.firstIndex(of: model) {
                    self.recordingsViewModels?.remove(at: index)
                    return true
                }
            }
        }
        return false
    }

    
    func delete(fileName : String)->Bool{
        let fileManager = FileManager.default
        let docDir = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let filePath = docDir.appendingPathComponent(fileName).appendingPathExtension("caf")
        do {
            try fileManager.removeItem(at: filePath)
            print("File deleted")
            return true
        }
        catch {
            print("Error")
        }
        return false
    }
    
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
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }

}

class RecordingsViewModel: NSObject {
    
    public var recordingName: String?
    public var trackTime: String?
    public var trackDurationInSeconds: Int

    init(recordingName :String) {
        self.recordingName = recordingName
        self.trackDurationInSeconds = 0
    }

}
