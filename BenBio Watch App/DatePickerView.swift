//
//  DatePickerView.swift
//  BenBio Watch App
//
//  Created by Gross, Benjamin on 25.02.24.
//

import SwiftUI

var birthday: String? = defaults.string(forKey: "birthday")
var components = DateComponents()

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
                    birthday = dateString
                    defaults.set(birthday, forKey: "birthday")
                    calcRhythm(birthday: DateFormat().date(from: birthday ?? "02/07/1979"))
                } else {
                    print("Could not convert DateComponents to Date")
                }
            }
        )
    }
    
    init() {
        birthday = defaults.string(forKey: "birthday")
        
        // Year is at position 7 to 10
        if let birthday = birthday, birthday.count >= 10 {
            let startIndex = birthday.index(birthday.startIndex, offsetBy: 6) // Index of 7th character
            let endIndex = birthday.index(birthday.startIndex, offsetBy: 9) // Index of 10th character
            let range = startIndex...endIndex
            let yearSubstring = String(birthday[range]) // Extracts characters 7 to 10
            if let year = Int(yearSubstring) {
                components.year = year
            } else {
                components.year = 1979
            }
        } else {
            components.year = 1979
        }
        // Month is at position 4 and 5
        if let birthday = birthday, birthday.count >= 5 {
            let startIndex = birthday.index(birthday.startIndex, offsetBy: 3) // Index of 4th character
            let endIndex = birthday.index(birthday.startIndex, offsetBy: 4) // Index of 5th character
            let range = startIndex...endIndex
            let monthSubstring = String(birthday[range]) // Extracts characters 4 to 5
            if let month = Int(monthSubstring) {
                components.month = month
            } else {
                components.month = 07
            }
        } else {
            components.month = 07
        }
        // Day is at position 1 and 2
        if let birthday = birthday, birthday.count >= 2 {
            let startIndex = birthday.startIndex // Index of 1st character
            let endIndex = birthday.index(birthday.startIndex, offsetBy: 1) // Index of 2nd character
            let range = startIndex...endIndex
            let daySubstring = String(birthday[range]) // Extracts characters 1 to 2
            if let day = Int(daySubstring) {
                components.day = day
            } else {
                components.day = 02
            }
        } else {
            components.day = 02
        }
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
            birthday = defaults.string(forKey: "birthday")
            
            // Year is at position 7 to 10
            if let birthday = birthday, birthday.count >= 10 {
                let startIndex = birthday.index(birthday.startIndex, offsetBy: 6) // Index of 7th character
                let endIndex = birthday.index(birthday.startIndex, offsetBy: 9) // Index of 10th character
                let range = startIndex...endIndex
                let yearSubstring = String(birthday[range]) // Extracts characters 7 to 10
                if let year = Int(yearSubstring) {
                    components.year = year
                } else {
                    components.year = 1979
                }
            } else {
                components.year = 1979
            }
            // Month is at position 4 and 5
            if let birthday = birthday, birthday.count >= 5 {
                let startIndex = birthday.index(birthday.startIndex, offsetBy: 3) // Index of 4th character
                let endIndex = birthday.index(birthday.startIndex, offsetBy: 4) // Index of 5th character
                let range = startIndex...endIndex
                let monthSubstring = String(birthday[range]) // Extracts characters 4 to 5
                if let month = Int(monthSubstring) {
                    components.month = month
                } else {
                    components.month = 07
                }
            } else {
                components.month = 07
            }
            // Day is at position 1 and 2
            if let birthday = birthday, birthday.count >= 2 {
                let startIndex = birthday.startIndex // Index of 1st character
                let endIndex = birthday.index(birthday.startIndex, offsetBy: 1) // Index of 2nd character
                let range = startIndex...endIndex
                let daySubstring = String(birthday[range]) // Extracts characters 1 to 2
                if let day = Int(daySubstring) {
                    components.day = day
                } else {
                    components.day = 02
                }
            } else {
                components.day = 02
            }
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
} //: DatePickerView

