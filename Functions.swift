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

// Use an explicit optional for the app group UserDefaults so we never
// implicitly fall back to `.standard` which can mix containers and
// trigger CFPrefs warnings. Access via `groupDefaults?` at call sites.
// Lazily access the app-group UserDefaults to avoid touching the CF
// preferences container at module load time (which can trigger
// cfprefsd warnings when entitlements/provisioning aren't applied yet).
@MainActor private final class GroupDefaultsState {
    var didLog: Bool = false
    // Set to true when the app has finished launching / scene is active.
    var allowed: Bool = false
}

@MainActor private let groupDefaultsState = GroupDefaultsState()

@MainActor private func _isGroupDefaultsAccessAllowed() -> Bool { groupDefaultsState.allowed }

@MainActor private func _setGroupDefaultsAccessAllowed() { groupDefaultsState.allowed = true }

@MainActor private func _didLogOnce() -> Bool { groupDefaultsState.didLog }

@MainActor private func _markDidLog() { groupDefaultsState.didLog = true }

@MainActor private func _makeGroupUserDefaults() -> UserDefaults? { return UserDefaults(suiteName: "group.org.seriousbenentertainment.BenBioWatch.Data") }

@MainActor public func enableGroupDefaultsAccess() {
    _setGroupDefaultsAccessAllowed()
}

@MainActor var groupDefaults: UserDefaults? {
    // Check access permission on the main actor
    if !_isGroupDefaultsAccessAllowed() {
        if !_didLogOnce() {
            _markDidLog()
            print("[BenBio] groupDefaults access blocked until app launch")
        }
        return nil
    }

    // Create the UserDefaults via main-actor helper (avoids touching CF prefs at load time)
    let ud = _makeGroupUserDefaults()

    if !_didLogOnce() {
        _markDidLog()
        if ud == nil {
            print("[BenBio] groupDefaults is nil — app group not available at runtime")
        } else {
            print("[BenBio] groupDefaults available: suiteName=group.org.seriousbenentertainment.BenBioWatch.Data")
        }
    }
    return ud
}

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

@MainActor public func calcRhythm(birthday : Date?) {
    guard let birthday else {
        return
    }
    var today: Date?
    
    // Setting Birthday and current date
    let calendarDate = Calendar.current.dateComponents([.day, .month, .year], from: Date())
    let day = String(calendarDate.day!) + "/"
    let month = String(calendarDate.month!)  + "/"
    let year = String(calendarDate.year!)
    let full: String = day + month + year
    today = DateFormat().date(from: full)
    guard let today else {
        return
    }
    let timeInterval = Int(today.timeIntervalSince(birthday))
    let delta = secondsToDays(seconds: timeInterval)
    let delta_1 = secondsToDays(seconds: timeInterval - 86400)

    // Calculating biorhythms
    let dpi: Float = 2 * Float.pi
    
    groupDefaults?.set(sin(dpi * Float(delta) / 23), forKey: "physical")
    groupDefaults?.set(sin(dpi * Float(delta) / 28), forKey: "emotional")
    groupDefaults?.set(sin(dpi * Float(delta) / 33), forKey: "mental")
    groupDefaults?.set(sin(dpi * Float(delta_1) / 23), forKey: "physical_1")
    groupDefaults?.set(sin(dpi * Float(delta_1) / 28), forKey: "emotional_1")
    groupDefaults?.set(sin(dpi * Float(delta_1) / 33), forKey: "mental_1")
    groupDefaults?.set(String(format: "%.0f", sin(dpi * Float(delta) / 23) * 100) +
                       " • " +
                       String(format: "%.0f", sin(dpi * Float(delta) / 28) * 100) +
                       " • " +
                       String(format: "%.0f", sin(dpi * Float(delta) / 33) * 100),
                      forKey: "Biorhythm")

}

// Retrieve HRV SDNN data from Apple health
public func getHRVdata() {
    guard HKHealthStore.isHealthDataAvailable() else {
        print("[BenBio] Health data not available")
        return
    }

    let healthStore = HKHealthStore()
    guard let sdnnType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
        print("[BenBio] SDNN quantity type not available")
        return
    }

    let readTypes: Set = [sdnnType]
    print("[BenBio] Requesting HRV authorization...")
    healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
        if let error = error {
            print("[BenBio] HRV authorization error: \(error.localizedDescription)")
            return
        }
        if !success {
            print("[BenBio] HRV authorization denied")
            return
        }

        // Query for the most recent HRV (SDNN) sample
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let query = HKSampleQuery(sampleType: sdnnType, predicate: predicate, limit: 1, sortDescriptors: [sort]) { _, results, error in
            if let error = error {
                print("[BenBio] HRV query error: \(error.localizedDescription)")
                return
            }

            guard let samples = results as? [HKQuantitySample], let latest = samples.first else {
                print("[BenBio] HRV: no samples found")
                return
            }

            // SDNN is provided in milliseconds
            let latestValueMS = latest.quantity.doubleValue(for: HKUnit(from: "ms"))
            let stressLevel = Int(latestValueMS)

            DispatchQueue.main.async {
                if stressLevel > 50 {
                    groupDefaults?.set("Low", forKey: "SDNNValue")
                } else if stressLevel > 25 {
                    groupDefaults?.set("Med.", forKey: "SDNNValue")
                } else {
                    groupDefaults?.set("High", forKey: "SDNNValue")
                }

                // Mirror thresholds for rMSSDValue (legacy behavior)
                if stressLevel > 50 {
                    groupDefaults?.set("Low", forKey: "rMSSDValue")
                } else if stressLevel > 25 {
                    groupDefaults?.set("Med.", forKey: "rMSSDValue")
                } else {
                    groupDefaults?.set("High", forKey: "rMSSDValue")
                }

                groupDefaults?.set(latestValueMS, forKey: "SDNNValueRaw")
            }
        }

        print("[BenBio] Executing HRV query...")
        healthStore.execute(query)
    }
} //: getHRVdata

// Retrieve Cardiofitness value from Apple health
public func getCardiofitness() {
    guard HKHealthStore.isHealthDataAvailable() else {
        print("[BenBio] Health data not available")
        return
    }

    let healthStore = HKHealthStore()
    guard let vo2Type = HKQuantityType.quantityType(forIdentifier: .vo2Max) else {
        print("[BenBio] vo2Max type not available")
        return
    }

    let readTypes: Set = [vo2Type]
    print("[BenBio] Requesting cardio fitness authorization...")
    healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
        if let error = error {
            print("[BenBio] Authorization request failed: \(error.localizedDescription)")
            return
        }
        if !success {
            print("[BenBio] Authorization denied")
            return
        }

        // Query the most recent VO2Max sample
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let query = HKSampleQuery(sampleType: vo2Type, predicate: predicate, limit: 1, sortDescriptors: [sort]) { _, samples, error in
            if let error = error {
                print("[BenBio] VO2 query error: \(error.localizedDescription)")
                return
            }

            guard let sample = samples?.first as? HKQuantitySample else {
                print("[BenBio] VO2: no samples found")
                DispatchQueue.main.async {
                    groupDefaults?.removeObject(forKey: "vo2MaxValue")
                }
                return
            }

            let vo2Unit = HKUnit(from: "mL/min·kg")
            let vo2Value = sample.quantity.doubleValue(for: vo2Unit)
            DispatchQueue.main.async {
                groupDefaults?.set(vo2Value, forKey: "vo2MaxValue")
            }
        }

        print("[BenBio] Executing VO2 query...")
        healthStore.execute(query)
    }
}//: getCardiofitness

// MARK: - Async HealthKit helpers and wrapper

private func requestAuthorizationAsync(healthStore: HKHealthStore, readTypes: Set<HKObjectType>) async -> Bool {
    return await withCheckedContinuation { cont in
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if let error = error {
                print("[BenBio] Authorization error: \(error.localizedDescription)")
                cont.resume(returning: false)
                return
            }
            cont.resume(returning: success)
        }
    }
}

private func fetchLatestQuantitySample(healthStore: HKHealthStore, sampleType: HKQuantityType, unit: HKUnit) async -> Double? {
    return await withCheckedContinuation { cont in
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 1, sortDescriptors: [sort]) { _, results, error in
            if let error = error {
                print("[BenBio] Query error: \(error.localizedDescription)")
                cont.resume(returning: nil)
                return
            }
            guard let sample = results?.first as? HKQuantitySample else {
                cont.resume(returning: nil)
                return
            }
            let value = sample.quantity.doubleValue(for: unit)
            cont.resume(returning: value)
        }
        healthStore.execute(query)
    }
}

public struct HealthMetrics {
    public let sdnnMS: Double?
    public let vo2Max: Double?
}

@MainActor public func fetchHealthMetricsAndStore() async -> HealthMetrics {
    // If HealthKit isn't available on this platform (or the app isn't entitled),
    // fall back to any previously stored metrics in the shared app-group
    // UserDefaults so the Mac app can still display the last known values.
    if !HKHealthStore.isHealthDataAvailable() {
        print("[BenBio] Health data not available — falling back to app-group defaults if present")

        if groupDefaults == nil {
            print("[BenBio] groupDefaults is nil — app group not available at runtime")
            return HealthMetrics(sdnnMS: nil, vo2Max: nil)
        }

        // Use `object(forKey:)` so we can detect absence vs a zero value.
        let sdnnObj = groupDefaults?.object(forKey: "SDNNValueRaw")
        let vo2Obj = groupDefaults?.object(forKey: "vo2MaxValue")

        func toDouble(_ obj: Any?) -> Double? {
            if let d = obj as? Double { return d }
            if let s = obj as? String, let d = Double(s) { return d }
            if let n = obj as? NSNumber { return n.doubleValue }
            return nil
        }

        let sdnnFallback = toDouble(sdnnObj)
        let vo2Fallback = toDouble(vo2Obj)

        if sdnnFallback != nil || vo2Fallback != nil {
            print("[BenBio] Falling back to group defaults: sdnn=\(sdnnFallback ?? -1), vo2=\(vo2Fallback ?? -1)")
            return HealthMetrics(sdnnMS: sdnnFallback, vo2Max: vo2Fallback)
        }

        print("[BenBio] No stored HealthKit metrics in group defaults")
        return HealthMetrics(sdnnMS: nil, vo2Max: nil)
    }

    let healthStore = HKHealthStore()
    guard let sdnnType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN),
          let vo2Type = HKQuantityType.quantityType(forIdentifier: .vo2Max) else {
        print("[BenBio] Required quantity types not available")
        return HealthMetrics(sdnnMS: nil, vo2Max: nil)
    }

    let readSet: Set<HKObjectType> = [sdnnType, vo2Type]
    print("[BenBio] Requesting HealthKit authorization for VO2 and HRV...")
    let authorized = await requestAuthorizationAsync(healthStore: healthStore, readTypes: readSet)
    if !authorized {
        print("[BenBio] HealthKit authorization denied")
        return HealthMetrics(sdnnMS: nil, vo2Max: nil)
    }

    print("[BenBio] Executing VO2 and HRV queries...")
    async let sdnnValue = fetchLatestQuantitySample(healthStore: healthStore, sampleType: sdnnType, unit: HKUnit(from: "ms"))
    async let vo2Value = fetchLatestQuantitySample(healthStore: healthStore, sampleType: vo2Type, unit: HKUnit(from: "mL/min·kg"))

    let sdnn = await sdnnValue
    let vo2 = await vo2Value

    // Store results to app-group defaults on MainActor
    if let sdnnVal = sdnn {
        let stressLevel = Int(sdnnVal)
        if stressLevel > 50 {
            groupDefaults?.set("Low", forKey: "SDNNValue")
        } else if stressLevel > 25 {
            groupDefaults?.set("Med.", forKey: "SDNNValue")
        } else {
            groupDefaults?.set("High", forKey: "SDNNValue")
        }

        // Mirror legacy rMSSD buckets
        if stressLevel > 50 {
            groupDefaults?.set("Low", forKey: "rMSSDValue")
        } else if stressLevel > 25 {
            groupDefaults?.set("Med.", forKey: "rMSSDValue")
        } else {
            groupDefaults?.set("High", forKey: "rMSSDValue")
        }

        groupDefaults?.set(sdnnVal, forKey: "SDNNValueRaw")
    } else {
        groupDefaults?.removeObject(forKey: "SDNNValue")
        groupDefaults?.removeObject(forKey: "rMSSDValue")
        groupDefaults?.removeObject(forKey: "SDNNValueRaw")
    }

    if let vo2Val = vo2 {
        groupDefaults?.set(vo2Val, forKey: "vo2MaxValue")
    } else {
        groupDefaults?.removeObject(forKey: "vo2MaxValue")
    }

    // Notify widgets to refresh with new HealthKit values
    WidgetCenter.shared.reloadAllTimelines()

    return HealthMetrics(sdnnMS: sdnn, vo2Max: vo2)
}

