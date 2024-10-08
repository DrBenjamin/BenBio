//
//  ContentView.swift
//  BenBio Mac App
//
//  Created by Gross, Benjamin on 25.02.24.
//
// Imports
import SwiftUI

// Set variables
nonisolated(unsafe) var birthday: String? = defaults.string(forKey: "birthday")
nonisolated(unsafe) var components = DateComponents()
nonisolated(unsafe) var calendarDate  = DateComponents()

struct ContentView: View {
    // Set variables
    @State var physical: Float = defaults.float(forKey: "physical")
    @State var emotional: Float = defaults.float(forKey: "emotional")
    @State var mental: Float = defaults.float(forKey: "mental")
    @State var physical_1: Float = defaults.float(forKey: "physical_1")
    @State var emotional_1: Float = defaults.float(forKey: "emotional_1")
    @State var mental_1: Float = defaults.float(forKey: "mental_1")
    @State private var calendarDate: DateComponents = {
        var calendar = Calendar.current
        return calendar.dateComponents([.day, .month, .year], from: Date())
    }()
    @State private var selectedDate: Date
    @State var vo2MaxValue: Double = defaults.double(forKey: "vo2MaxValue")
    @State var SDNNValue: String = defaults.string(forKey: "SDNNValue") ?? "Low"
    @State var rMSSDValue: String = defaults.string(forKey: "rMSSDValue") ?? "Low"
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
                    refreshView()
                } else {
                    print("Could not convert DateComponents to Date")
                }
            }
        )
    }
    
    init() {
        print("App Start")
        birthday = defaults.string(forKey: "birthday")
        print(birthday as Any)
        if birthday == nil {
            birthday = "02/07/1979"
            defaults.set(birthday, forKey: "birthday")
        }
        calcRhythm(birthday: DateFormat().date(from: birthday ?? "02/07/1979"))
        
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
    } //: init
    
    var body: some View {
        Image("BackGround")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
        VStack {
            DatePicker("Select your birthday", selection: selectedDateProxy, displayedComponents: .date)
            Spacer()
            
            Group {
                if physical < -0.05 {
                    if physical > physical_1 {
                        Text("💪 \(String(format: "%.0f", physical * 100))%  ⬆️").font(.system(size: 30)).foregroundStyle(.orange)
                    } else {
                        Text("💪 \(String(format: "%.0f", physical * 100))%  ⬇️").font(.system(size: 30)).foregroundStyle(.orange)
                    }
                }
                if physical >= -0.05 && physical <= 0.05 {
                    if physical < 0 {
                        if physical > physical_1 {
                            Text("💪 \(String(format: "%.0f", physical * 100))%  ⬆️").font(.system(size: 30)).foregroundStyle(.red)
                        } else {
                            Text("💪 \(String(format: "%.0f", physical * 100))%  ⬇️").font(.system(size: 30)).foregroundStyle(.red)
                        }
                    }
                    else {
                        if physical > physical_1 {
                            Text("💪 +\(String(format: "%.0f", physical * 100))%  ⬆️").font(.system(size: 30)).foregroundStyle(.red)
                        } else {
                            Text("💪 +\(String(format: "%.0f", physical * 100))%  ⬇️").font(.system(size: 30)).foregroundStyle(.red)
                        }
                    }
                }
                if physical > 0.05 {
                    if physical > physical_1 {
                        Text("💪 +\(String(format: "%.0f", physical * 100))%  ⬆️").font(.system(size: 30)).foregroundStyle(.green)
                    } else {
                        Text("💪 +\(String(format: "%.0f", physical * 100))%  ⬇️").font(.system(size: 30)).foregroundStyle(.green)
                    }
                }
            } //: Group
            Group {
                if emotional < -0.05 {
                    if emotional > emotional_1 {
                        Text("🧡 \(String(format: "%.0f", emotional * 100))%  ⬆️").font(.system(size: 30)).foregroundStyle(.orange)
                    } else {
                        Text("🧡 \(String(format: "%.0f", emotional * 100))%  ⬇️").font(.system(size: 30)).foregroundStyle(.orange)
                    }
                }
                if emotional >= -0.05 && emotional <= 0.05 {
                    if emotional < 0 {
                        if emotional > emotional_1 {
                            Text("🧡 \(String(format: "%.0f", emotional * 100))%  ⬆️").font(.system(size: 30)).foregroundStyle(.red)
                        } else {
                            Text("🧡 \(String(format: "%.0f", emotional * 100))%  ⬇️").font(.system(size: 30)).foregroundStyle(.red)
                        }
                    }
                    else {
                        if emotional > emotional_1 {
                            Text("🧡 +\(String(format: "%.0f", emotional * 100))%  ⬆️").font(.system(size: 30)).foregroundStyle(.red)
                        } else {
                            Text("🧡 +\(String(format: "%.0f", emotional * 100))%  ⬇️").font(.system(size: 30)).foregroundStyle(.red)
                        }
                    }
                }
                if emotional > 0.05 {
                    if emotional > emotional_1 {
                        Text("🧡 +\(String(format: "%.0f", emotional * 100))%  ⬆️").font(.system(size: 30)).foregroundStyle(.green)
                    } else {
                        Text("🧡 +\(String(format: "%.0f", emotional * 100))%  ⬇️").font(.system(size: 30)).foregroundStyle(.green)
                    }
                }
            } //: Group
            Group {
                if mental < -0.05 {
                    if mental > mental_1 {
                        Text("🧠 \(String(format: "%.0f", mental * 100))%  ⬆️").font(.system(size: 30)).foregroundStyle(.orange)
                    } else {
                        Text("🧠 \(String(format: "%.0f", mental * 100))%  ⬇️").font(.system(size: 30)).foregroundStyle(.orange)
                    }
                }
                if mental >= -0.05 && mental <= 0.05 {
                    if mental < 0 {
                        if mental > mental_1 {
                            Text("🧠 \(String(format: "%.0f", mental * 100))%  ⬆️").font(.system(size: 30)).foregroundStyle(.red)
                        } else {
                            Text("🧠 \(String(format: "%.0f", mental * 100))%  ⬇️").font(.system(size: 30)).foregroundStyle(.red)
                        }
                    }
                    else {
                        if mental > mental_1 {
                            Text("🧠 +\(String(format: "%.0f", mental * 100))%  ⬆️").font(.system(size: 30)).foregroundStyle(.red)
                        } else {
                            Text("🧠 +\(String(format: "%.0f", mental * 100))%  ⬇️").font(.system(size: 30)).foregroundStyle(.red)
                        }
                    }
                }
                if mental > 0.05 {
                    if mental > mental_1 {
                        Text("🧠 +\(String(format: "%.0f", mental * 100))%  ⬆️").font(.system(size: 30)).foregroundStyle(.green)
                    } else {
                        Text("🧠 +\(String(format: "%.0f", mental * 100))%  ⬇️").font(.system(size: 30)).foregroundStyle(.green)
                    }
                }
            } //: Group
            Group {
                VStack(spacing: 0) {
                    Text("Cardiofitness: \(String(vo2MaxValue))").font(.system(size: 14)).foregroundStyle(.teal)
                    Text("Stresslevel (today): \(SDNNValue)").font(.system(size: 14)).foregroundStyle(.teal)
                    Text("Stresslevel (now): \(rMSSDValue)").font(.system(size: 14)).foregroundStyle(.teal)
                }
                if physical >= -0.05 && physical <= 0.05 || emotional >= -0.05 && emotional <= 0.05 || mental >= -0.05 && mental <= 0.05 {
                    Text("Advise ⚠️").font(.system(size: 24)).foregroundStyle(.teal)
                } else {
                    if physical + emotional + mental > 1 {
                        Text("Advise 🥳").font(.system(size: 24)).foregroundStyle(.teal)
                    }
                    if physical + emotional + mental >= -1 && physical + emotional + mental <= 1 {
                        Text("Advise 😃").font(.system(size: 24)).foregroundStyle(.teal)
                    }
                    if physical + emotional + mental < -1 {
                        Text("Advise 😴").font(.system(size: 24)).foregroundStyle(.teal)
                    }
                }
            } //: Group
            .padding()
        } //:VStack
        .onAppear {
            refreshView()
        }
    } //: View
    
    func refreshView() {
        physical = defaults.float(forKey: "physical")
        emotional = defaults.float(forKey: "emotional")
        mental = defaults.float(forKey: "mental")
        physical_1 = defaults.float(forKey: "physical_1")
        emotional_1 = defaults.float(forKey: "emotional_1")
        mental_1 = defaults.float(forKey: "mental_1")
        vo2MaxValue = defaults.double(forKey: "vo2MaxValue")
        SDNNValue = defaults.string(forKey: "SDNNValue") ?? "Low"
        rMSSDValue = defaults.string(forKey: "rMSSDValue") ?? "Low"
    } //: refreshView
} //: ContentView

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
