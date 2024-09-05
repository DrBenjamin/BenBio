//
//  ContentView.swift
//  BenBioWatch Watch App
//
//  Created by Gross, Benjamin on 25.02.24.
//
// Imports
import SwiftUI

struct ContentView: View {
    // Set variables
    @State var physical: Float = defaults.float(forKey: "physical")
    @State var emotional: Float = defaults.float(forKey: "emotional")
    @State var mental: Float = defaults.float(forKey: "mental")
    @State var physical_1: Float = defaults.float(forKey: "physical_1")
    @State var emotional_1: Float = defaults.float(forKey: "emotional_1")
    @State var mental_1: Float = defaults.float(forKey: "mental_1")
    @Environment(\.scenePhase) var scenePhase
    @State private var calendarDate: DateComponents = {
        var calendar = Calendar.current
        return calendar.dateComponents([.day, .month, .year], from: Date())
    }()
    init() {
        print("App Start")
        birthday = defaults.string(forKey: "birthday")
        if birthday == nil {
            birthday = "02/07/1979"
            defaults.set(birthday, forKey: "birthday")
        }
        calcRhythm(birthday: DateFormat().date(from: birthday ?? "02/07/1979"))
    } //: init
    
    var body: some View {
        NavigationView {
            VStack {
                Text("").font(.system(size: 22))
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
                .onChange(of: scenePhase) { newPhase, oldPhase in
                    if newPhase == .active {
                        print("Active")
                        calcRhythm(birthday: DateFormat().date(from: birthday ?? "02/07/1979"))
                    } else if newPhase == .inactive {
                        print("Inactive")
                    } else if newPhase == .background {
                        print("Background")
                    }
                } //: onChange
                
                NavigationLink(destination: DatePickerView()) {
                    Text("Change birthday")
                } //: NavigationLink
                .onAppear() {
                    refreshView()
                }
            } //: VStack
            .navigationTitle("Ben Bio Watch")
            .padding()
            .onAppear {
                refreshView()
            }
        } //: NavigationView
    } //: View
    
    func refreshView() {
        physical = defaults.float(forKey: "physical")
        emotional = defaults.float(forKey: "emotional")
        mental = defaults.float(forKey: "mental")
        physical_1 = defaults.float(forKey: "physical_1")
        emotional_1 = defaults.float(forKey: "emotional_1")
        mental_1 = defaults.float(forKey: "mental_1")
    }
} //: ContentView

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
