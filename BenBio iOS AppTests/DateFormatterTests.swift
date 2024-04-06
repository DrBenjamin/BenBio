//
//  DateFormatterTests.swift
//  BenBio iOS AppTests
//
//  Created by Gross, Benjamin on 05.04.24.
//

import XCTest
@testable import BenBio_iOS_App

final class DateFormatterTests: XCTestCase {

    func testSuccessfulDateFormatting() {
        // Given (Arrenge)
        let enteredDate = "02/07/1979"
        
        // When (Act)
        let date = DateFormat().date(from: enteredDate)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let expectedDate = dateFormatter.date(from: "02/07/1979")
        
        // Then (Assert)
        XCTAssertEqual(date, expectedDate)
    }

}
