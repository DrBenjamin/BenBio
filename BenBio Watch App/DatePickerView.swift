//
//  DatePickerView.swift
//  BenBio Watch App
//
//  Created by Gross, Benjamin on 25.02.24.
//

import SwiftUI

struct DatePickerView: View {
    @State private var calendarDate: DateComponents
    @State private var selectedDate: Date

    var selectedDateProxy: Binding<Date> {
        Binding<Date>(
            get: {
                // Convert the `calendarDate` to `Date`
                return Calendar.current.date(from: calendarDate) ?? Date()
            },
            set: {
                let timeZone = TimeZone.current
                var calendar = Calendar(identifier: .gregorian)
                calendar.timeZone = timeZone
                
                // Store the new date value in `calendarDate` as `DateComponents`
                calendarDate = Calendar.current.dateComponents([.day, .month, .year], from: $0)
                if let date = calendar.date(from: calendarDate) {
                    // Format the Date into a string
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM/yyyy"
                    dateFormatter.timeZone = timeZone
                    let dateString = dateFormatter.string(from: date)
                    groupDefaults?.set(dateString, forKey: "birthday")
                    calcRhythm(birthday: DateFormat().date(from: dateString))
                } else {
                    print("Could not convert DateComponents to Date")
                }
            }
        )
    }
    
    init() {
        let storedBirthday = groupDefaults?.string(forKey: "birthday") ?? "02/07/1979"
        let components = Self.dateComponents(from: storedBirthday)

        // Use the current calendar to create a Date from components
        if let defaultDate = Calendar.current.date(from: components) {
            _selectedDate = State(initialValue: defaultDate)
        } else {
            // Handle the case where the date couldn't be created,
            // for example, by using the current date:
            _selectedDate = State(initialValue: Date())
        }
        _calendarDate = State(initialValue: components)
    }
    
    var body: some View {
        VStack {
            DatePicker(
                "Select Birthday", selection: selectedDateProxy, displayedComponents: .date)
        } //: VStack
        .onAppear {
            let storedBirthday = groupDefaults?.string(forKey: "birthday") ?? "02/07/1979"
            let components = Self.dateComponents(from: storedBirthday)

            // Use the current calendar to create a Date from components
            if let defaultDate = Calendar.current.date(from: components) {
                self._selectedDate.wrappedValue = defaultDate
            } else {
                // Handle the case where the date couldn't be created,
                // for example, by using the current date:
                self._selectedDate.wrappedValue = Date()
            }
            self._calendarDate.wrappedValue = components
        } //: onAppear
    } //: View

    private static func dateComponents(from birthday: String) -> DateComponents {
        var components = DateComponents()

        if birthday.count >= 10 {
            let startIndex = birthday.index(birthday.startIndex, offsetBy: 6)
            let endIndex = birthday.index(birthday.startIndex, offsetBy: 9)
            let range = startIndex...endIndex
            let yearSubstring = String(birthday[range])
            components.year = Int(yearSubstring) ?? 1979
        } else {
            components.year = 1979
        }

        if birthday.count >= 5 {
            let startIndex = birthday.index(birthday.startIndex, offsetBy: 3)
            let endIndex = birthday.index(birthday.startIndex, offsetBy: 4)
            let range = startIndex...endIndex
            let monthSubstring = String(birthday[range])
            components.month = Int(monthSubstring) ?? 7
        } else {
            components.month = 7
        }

        if birthday.count >= 2 {
            let endIndex = birthday.index(birthday.startIndex, offsetBy: 1)
            let range = birthday.startIndex...endIndex
            let daySubstring = String(birthday[range])
            components.day = Int(daySubstring) ?? 2
        } else {
            components.day = 2
        }

        return components
    }
} //: DatePickerView

