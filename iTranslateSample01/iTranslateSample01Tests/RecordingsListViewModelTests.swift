//
//  RecordingsListViewModelTests.swift
//  iTranslateSample01Tests
//
//  Created by Tarun Mukesh Kinger on 02/03/20.
//  Copyright © 2020 iTranslate. All rights reserved.
//

import XCTest

class RecordingsListViewModelTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testRecordingListViewModel() {
        let recordName = "Test"
        let recordModel = RecordingsViewModel.init(recordingName: recordName)
        XCTAssertTrue(recordModel.recordingName == recordName)
    }
    
    func testCreateRecordingsViewModel() {
        
        let filecount = RecorderUtility.fetchFileNames()?.count
        let recordModel = RecordingsListViewModel()
        recordModel.createRecordingsViewModel()
        XCTAssertTrue(recordModel.recordingsViewModelsArray?.count == filecount)
    }
    
    func testRemoveRecording() {
        let filecount = (RecorderUtility.fetchFileNames()?.count)!
        let recordListModel = RecordingsListViewModel()
        recordListModel.createRecordingsViewModel()
        
        if filecount > 0 {
            let recordModel = recordListModel.recordingsViewModelsArray?.last
             _ = recordListModel.removeRecording(recordModel)
            XCTAssertFalse((recordListModel.recordingsViewModelsArray?.contains(recordModel!))!)
        }

    }

}
