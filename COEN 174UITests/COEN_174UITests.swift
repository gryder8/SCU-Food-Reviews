//
//  COEN_174UITests.swift
//  COEN 174UITests
//
//  Created by Gavin Ryder on 1/12/23.
//

import XCTest

final class COEN_174UITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLaunch() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments = ["UITesting"]
        app.launch()
        
        
        if ProcessInfo.processInfo.arguments.contains("foodList") {
            let list = app.scrollViews["foodList"]
            XCTAssertTrue(list.exists)
        }

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformanceAndStressTestAPI() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
