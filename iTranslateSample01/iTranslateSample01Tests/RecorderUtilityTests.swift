//
//  RecorderUtilityTests.swift
//  iTranslateSample01Tests
//
//  Created by Tarun Mukesh Kinger on 02/03/20.
//  Copyright © 2020 iTranslate. All rights reserved.
//

import XCTest

class RecorderUtilityTests: XCTestCase {

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
    
    func testGetDocumentsDirectory() {
        let docPath = RecorderUtility.getDocumentsDirectory()
        XCTAssertTrue(docPath != nil)
    }
    
    func testGetLastFileIndex() {
        let lastIndex = RecorderUtility.getLastFileIndex()
        let fileURLS = RecorderUtility.fetchFileNames()
        if fileURLS!.count > 0 {
            XCTAssertTrue(lastIndex > 0)
        } else {
            XCTAssertTrue(lastIndex == 0)
        }
    }
}
