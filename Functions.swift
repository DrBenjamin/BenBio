//
//  Functions.swift
//  BenBio
//
//  Created by Gross, Benjamin on 25.02.24.
//

import Foundation
import SwiftUI

let defaults = UserDefaults.standard

func dateWithoutTime(date: Date) -> Date {
    return Calendar.current.startOfDay(for: date)
}

public func DateFormat() -> DateFormatter {
    let x = DateFormatter()
    x.dateFormat = "dd/MM/yyyy"
    x.timeZone = TimeZone(abbreviation: "GMT")
    return x
}

public func secondsToDays(seconds : Int) -> (Int) {
    return (seconds / 86400)
}

public func calcRhythm(birthday : Date?) {
    var today: Date?
    
    // Setting Birthday and current date
    let calendarDate = Calendar.current.dateComponents([.day, .month, .year], from: Date())
    let day = String(calendarDate.day!) + "/"
    let month = String(calendarDate.month!)  + "/"
    let year = String(calendarDate.year!)
    let full: String = day + month + year
    today = DateFormat().date(from: full)
    let timeInterval = Int(exactly: (today?.timeIntervalSince(birthday!))!) ?? 0
    let delta = secondsToDays(seconds: timeInterval)

    // Calculate biorhythm
    let dpi: Float = 2 * Float.pi
    defaults.set(sin(dpi * Float(delta) / 23), forKey: "physical")
    defaults.set(sin(dpi * Float(delta) / 28), forKey: "emotional")
    defaults.set(sin(dpi * Float(delta) / 33), forKey: "mental")
    defaults.set(sin(dpi * Float(16308) / 23), forKey: "physical_1")
    defaults.set(sin(dpi * Float(16308) / 28), forKey: "emotional_1")
    defaults.set(sin(dpi * Float(16308) / 33), forKey: "mental_1")
}
