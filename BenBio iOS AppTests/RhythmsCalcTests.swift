//
//  RhythmsCalcTests.swift
//  BenBio iOS AppTests
//
//  Created by Gross, Benjamin on 05.04.24.
//

import XCTest
@testable import BenBio_iOS_App

final class RhythmsCalcTests: XCTestCase {

    func testSuccessfulRhythmCalculation() {
        // Given (Arrenge)
        let enteredSeconds = 10000000
        
        // When (Act)
        let days = secondsToDays(seconds: enteredSeconds)
        
        // Then (Assert)
        XCTAssertEqual(days, 115)
    }
}
