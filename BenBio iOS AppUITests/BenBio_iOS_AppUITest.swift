//
//  BenBio_iOS_AppUITest.swift
//  BenBio iOS AppUITests
//
//  Created by Benjamin Groß on 06.04.24.
//

import XCTest

final class BenBio_iOS_AppUITest: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    override func tearDownWithError() throws {
    }

        func test_BenBioView_SelectDate_ChangeValues() throws {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
            
            let datePickersQuery = XCUIApplication().datePickers
            datePickersQuery/*@START_MENU_TOKEN@*/.pickerWheels["2."].press(forDuration: 0.8);/*[[".pickers.pickerWheels[\"2.\"]",".tap()",".press(forDuration: 0.8);",".pickerWheels[\"2.\"]"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/
            
            
            let app = XCUIApplication()
            app.staticTexts["💪 -73%  ⬇️"].tap()
            app.staticTexts["Advise 😃"].tap()
                        
    }
}
