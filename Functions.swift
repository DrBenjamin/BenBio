//
//  Functions.swift
//  BenBio
//
//  Created by Gross, Benjamin on 25.02.24.
//

import Foundation
import SwiftUI
import HealthKit
import WidgetKit

nonisolated(unsafe) let defaults = UserDefaults(suiteName: "group.BenBioWatch.Data")!

func dateWithoutTime(date: Date) -> Date {
    return Calendar.current.startOfDay(for: date)
}

public func DateFormat() -> DateFormatter {
    let x = DateFormatter()
    x.dateFormat = "dd/MM/yyyy"
    x.timeZone = TimeZone(abbreviation: "GMT+1:00")
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
    let delta_1 = secondsToDays(seconds: timeInterval - 86400)

    // Calculating biorhythms
    let dpi: Float = 2 * Float.pi
    defaults.set(sin(dpi * Float(delta) / 23), forKey: "physical")
    defaults.set(sin(dpi * Float(delta) / 28), forKey: "emotional")
    defaults.set(sin(dpi * Float(delta) / 33), forKey: "mental")
    defaults.set(sin(dpi * Float(delta_1) / 23), forKey: "physical_1")
    defaults.set(sin(dpi * Float(delta_1) / 28), forKey: "emotional_1")
    defaults.set(sin(dpi * Float(delta_1) / 33), forKey: "mental_1")
    defaults.set(String(format: "%.0f", sin(dpi * Float(delta) / 23) * 100) +
                 " • " +
                 String(format: "%.0f", sin(dpi * Float(delta) / 28) * 100) +
                 " • " +
                 String(format: "%.0f", sin(dpi * Float(delta) / 33) * 100),
                 forKey: "Biorhythm")
    defaults.synchronize()
    WidgetCenter.shared.reloadAllTimelines()
}

// Retrieve HRV SDNN data from Apple health
public func getHRVdata() {
    let healthStore = HKHealthStore()
    var stresslevel: Int = 0
    var stresslevel_now: Int = 0
    // Create instance of HKQuantityType for heart rate variability SDNN
    let sdnnType: Set = [
        HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
    ]

    print("Requesting authorization...")
    healthStore.requestAuthorization(toShare: nil, read: sdnnType) { success, error in
        if let error = error {
            print("Authorization request failed: \(error.localizedDescription)")
            return
        }
        if success {
            print("Authorization granted")
            
            guard let type = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
                print("Failed to create quantity type")
                return
            }
            
            let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictStartDate)
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error)
                in
                if let error = error {
                    print("Query Error: \(error.localizedDescription)")
                    return
                }
                
                guard let results = results as? [HKQuantitySample] else {
                    print("Fehler beim Abrufen der Daten: \(String(describing: error))")
                    return
                }
                
                for result in results {
                    //print("Found sample: \(result)")
                    let date = result.startDate
                    let value = result.quantity.doubleValue(for: HKUnit(from: "ms"))
                    print("\(date),\(value)")
                    stresslevel = Int(value)
                }
                stresslevel_now = stresslevel
                DispatchQueue.main.async {
                    if stresslevel > 50 {
                        defaults.set("Low", forKey: "SDNNValue")
                    } else
                        if stresslevel > 25 {
                        defaults.set("Med.", forKey: "SDNNValue")
                    } else {
                        defaults.set("High", forKey: "SDNNValue")
                    }
                    if stresslevel_now > 50 {
                        defaults.set("Low", forKey: "rMSSDValue")
                    } else
                        if stresslevel_now > 25 {
                        defaults.set("Med.", forKey: "rMSSDValue")
                        } else {
                            defaults.set("High", forKey: "rMSSDValue")
                        }
                }
            }
            
            print("Executing query...")
            healthStore.execute(query)
        } else {
            print("Authorization denied")
        }
    }//: healthStore
} //: getHRVdata

// Retrieve Cardiofitness value from Apple health
public func getCardiofitness() {
    let healthStore = HKHealthStore()
    
    // Create instance of HKQuantityType for vo2Max
    let allTypes: Set = [
        HKQuantityType.quantityType(forIdentifier: .vo2Max)!,
    ]
    
    print("Requesting authorization...")
    healthStore.requestAuthorization(toShare: nil, read: allTypes) { success, error in
        if let error = error {
            print("Authorization request failed: \(error.localizedDescription)")
            return
        }
        if success {
            print("Authorization granted")
            
            guard let type = HKQuantityType.quantityType(forIdentifier: .vo2Max) else {
                print("Failed to create quantity type")
                return
            }
            
            let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictStartDate)
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (_, samples, error)
                in
                if let error = error {
                    print("Query Error: \(error.localizedDescription)")
                    return
                }
                
                guard let samples = samples as? [HKQuantitySample] else {
                    print("No samples found")
                    return
                }
                
                let vo2MaxValues = samples.map { $0.quantity.doubleValue(for: HKUnit(from: "mL/min·kg")) }
                DispatchQueue.main.async {
                    defaults.set(vo2MaxValues.last, forKey: "vo2MaxValue")
                }
            }
            print("Executing query...")
            healthStore.execute(query)
        } else {
            print("Authorization denied")
        }
    }//: healthStore
}//: getCardiofitness
