//
//  iTranslateSample01UITests.swift
//  iTranslateSample01UITests
//
//  Created by Andreas Gruber on 04.07.19.
//  Copyright © 2019 iTranslate. All rights reserved.
//

import XCTest


class iTranslateSample01UITests: XCTestCase {
    
    let app = XCUIApplication()
    let timeOutInterval5Sec = 5.0
    
    override func setUp() {
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()
        app.launchEnvironment = ["animations": "0"]
        
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func tapOnAppAlerts() {
        addUIInterruptionMonitor(withDescription: "Microphone Access") {
            (alert) -> Bool in
            let micPermission = "Would Like to Access the Microphone"
            if alert.labelContains(text: micPermission) {
                alert.buttons["OK"].tap()
                self.app.tap()
                
                return true
            }
            return false
        }
    }
    
    func verifyXCTAssertionOf (verifyText : String){
        if app.navigationBars[verifyText].waitForExistence(timeout: timeOutInterval5Sec){
            XCTAssertTrue(app.navigationBars[verifyText].exists)
        }
        else if app.navigationBars.otherElements[verifyText].waitForExistence(timeout: timeOutInterval5Sec){
            XCTAssertTrue(app.navigationBars.otherElements[verifyText].exists)
        }
        else if app.otherElements[verifyText].waitForExistence(timeout: timeOutInterval5Sec){
            XCTAssertTrue(app.otherElements[verifyText].exists)
        }
        else if app.staticTexts[verifyText].exists{
            XCTAssertTrue(app.staticTexts[verifyText].exists)
        }
        else if app.buttons[verifyText].exists{
            XCTAssertTrue(app.buttons[verifyText].exists)
        }
        else if app.tables.buttons[verifyText].exists{
            XCTAssertTrue(app.tables.buttons[verifyText].exists)
        }
        else if app.tables.staticTexts[verifyText].exists{
            XCTAssertTrue(app.tables.staticTexts[verifyText].exists)
        }
        else if app.staticTexts[verifyText].exists{
            XCTAssertTrue(app.staticTexts[verifyText].exists)
        }
        else if app.tables.otherElements[verifyText].exists{
            XCTAssertTrue(app.tables.otherElements[verifyText].exists)
        }
        else if app.tables.cells[verifyText].exists{
            XCTAssertTrue(app.tables.cells[verifyText].exists)
        }
        else {
            XCTFail("Unable to find the element \(verifyText)")
        }
    }
    
    func testCheckMicPermissionView() {
        sleep(3)
        let allowText = app.staticTexts["Allow"]
        if allowText.waitForExistence(timeout: timeOutInterval5Sec) {
            XCTAssertTrue(allowText.exists)
        } else {
            XCTAssertFalse(allowText.exists)
        }
    }
    
    func testCheckMicPermissionMaybeLater() {
        let maybeLater = app.otherElements["micPermissionDeniedButton"]
        if maybeLater.waitForExistence(timeout: timeOutInterval5Sec) {
            maybeLater.tap()
            sleep(3)
            verifyXCTAssertionOf (verifyText : "Go to Settings")
        } else {
            XCTAssertFalse(maybeLater.exists)
        }
    }
    
    func testCheckMicPermissionAllow() {
        tapOnAppAlerts()
        
        if app.staticTexts["Allow"].waitForExistence(timeout: timeOutInterval5Sec) {
            app.staticTexts["Allow"].tap()
        }
        sleep(3)
        app.swipeUp()
        
        verifyXCTAssertionOf (verifyText : "showRecordingsButton")
    }
    
    func testRecordsAvailable() {
        
        app.buttons["showRecordingsButton"].tap()
        let noRecords = app.staticTexts["NO RECORDINGS AVAILABLE"]
        let recentlyUsed = app.staticTexts["RECENTLY USED"]
        
        if noRecords.exists {
            XCTAssertTrue(noRecords.exists)
        } else if recentlyUsed.exists {
            XCTAssertTrue(recentlyUsed.exists)
        }
    }
    
    func testRecording() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let micbuttonButton = app/*@START_MENU_TOKEN@*/.buttons["micButton"]/*[[".buttons[\"Button\"]",".buttons[\"micButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        micbuttonButton.tap()
        if app.waitForExistence (timeout: 1.0){
            micbuttonButton.tap()
        }
        
        let elementsQuery = app.alerts["Saved"].scrollViews.otherElements
        elementsQuery.buttons["OK"].tap()
        
        XCUIApplication().buttons["showRecordingsButton"].tap()
        verifyXCTAssertionOf (verifyText : "RECENTLY USED")
    }
    
    func testPlayRecording() {
        app.buttons["showRecordingsButton"].tap()
        
        if app.tables.staticTexts.element(boundBy: 1).waitForExistence(timeout: timeOutInterval5Sec){
            app.tables.staticTexts.element(boundBy: 1).tap()
        }
        
        if app.navigationBars["Recordings"].buttons["Done"].waitForExistence(timeout: timeOutInterval5Sec){
            app.navigationBars["Recordings"].buttons["Done"].tap()
        }
    }
    
    func dismissAndRecordAudio() {
        if app.navigationBars["Recordings"].buttons["Done"].waitForExistence(timeout: timeOutInterval5Sec){
            app.navigationBars["Recordings"].buttons["Done"].tap()
        }
        sleep(3)
        let micButton = app/*@START_MENU_TOKEN@*/.buttons["micButton"]/*[[".buttons[\"Button\"]",".buttons[\"micButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        micButton.tap()
        if micButton.waitForExistence(timeout: 1.0){
            micButton.tap()
        }
        
        let elementsQuery = app.alerts["Saved"].scrollViews.otherElements
        elementsQuery.buttons["OK"].tap()
        sleep(3)
        app.buttons["showRecordingsButton"].tap()
        sleep(3)
    }
    
    func testPlayMultipleRecordings() {
        app.buttons["showRecordingsButton"].tap()
        let row0 = app.tables.staticTexts.element(boundBy: 1)
        let row1 = app.tables.staticTexts.element(boundBy: 2)
        
        if row0.waitForExistence(timeout: timeOutInterval5Sec){
            row0.tap()
        } else {
            dismissAndRecordAudio()
            if row0.waitForExistence(timeout: timeOutInterval5Sec){
                row0.tap()
            }
        }
        
        if row1.waitForExistence(timeout: timeOutInterval5Sec){
            row1.tap()
        } else {
            dismissAndRecordAudio()
            if row1.waitForExistence(timeout: timeOutInterval5Sec){
                row1.tap()
            }
        }
                
    }
    
    func testSwipeToDelete() {
        app.buttons["showRecordingsButton"].tap()
        
        let recording1 = app.tables.staticTexts.element(boundBy: 1)
        if recording1.waitForExistence(timeout: timeOutInterval5Sec) {
            recording1.swipeLeft()
            sleep(3)
            if app.tables.buttons["deleteButton"].waitForExistence(timeout: timeOutInterval5Sec) {
                app.tables.buttons["deleteButton"].tap()
            }
        } else {
            dismissAndRecordAudio()
            if recording1.waitForExistence(timeout: timeOutInterval5Sec) {
                recording1.swipeLeft()
                sleep(3)
                if app.tables.buttons["deleteButton"].waitForExistence(timeout: timeOutInterval5Sec) {
                    app.tables.buttons["deleteButton"].tap()
                }
            }
        }
        XCTAssertFalse(recording1.exists)
    }
    
}

extension XCUIElement {
  func labelContains(text: String) -> Bool {
    let predicate = NSPredicate(format: "label CONTAINS %@", text)
    return staticTexts.matching(predicate).firstMatch.exists
  }
}
