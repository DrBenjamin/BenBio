//
//  ContentView.swift
//  BenBioWatch Watch App
//
//  Created by Gross, Benjamin on 25.02.24.
//
// Imports
import SwiftUI

struct ContentView: View {
    @State private var physical: Float = groupDefaults?.float(forKey: "physical") ?? 0.0
    @State private var emotional: Float = groupDefaults?.float(forKey: "emotional") ?? 0.0
    @State private var mental: Float = groupDefaults?.float(forKey: "mental") ?? 0.0
    @State private var physical_1: Float = groupDefaults?.float(forKey: "physical_1") ?? 0.0
    @State private var emotional_1: Float = groupDefaults?.float(forKey: "emotional_1") ?? 0.0
    @State private var mental_1: Float = groupDefaults?.float(forKey: "mental_1") ?? 0.0
    @State private var cardioValue: String = groupDefaults?.string(forKey: "rMSSDValue") ?? "33"
    @Environment(\.scenePhase) var scenePhase

    init() {
        print("Watch App Start")
        let storedBirthday = groupDefaults?.string(forKey: "birthday")
        if storedBirthday == nil {
            groupDefaults?.set("02/07/1979", forKey: "birthday")
        }
        let birthdayValue = groupDefaults?.string(forKey: "birthday") ?? "02/07/1979"
        calcRhythm(birthday: DateFormat().date(from: birthdayValue))
        //getCardiofitness()
        //getHRVdata()
    } //: init
    
    var body: some View {
        NavigationView {
            VStack(spacing: 6) {
                rhythmRow(title: "Physis", emoji: "💪", value: physical, previous: physical_1)
                rhythmRow(title: "Emo", emoji: "🧡", value: emotional, previous: emotional_1)
                rhythmRow(title: "Mental", emoji: "🧠", value: mental, previous: mental_1)

                stressRow

                NavigationLink(destination: DatePickerView()) {
                    Label("Birthday", systemImage: "calendar")
                        .font(.caption2.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .allowsTightening(true)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 3)
                }
                .buttonStyle(.bordered)
                .controlSize(.mini)
                .tint(.blue)
            }
            .padding(.horizontal, 10)
            .padding(.top, 11)
            .padding(.bottom, 2)
            .navigationTitle("BenBio")
            .onAppear {
                refreshAll()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active || newPhase == .inactive {
                    refreshAll()
                }
            }
        }
    }

    private var stressRow: some View {
            HStack(spacing: 6) {
            Image(systemName: "waveform.path.ecg")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Cardio")
                .font(.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .allowsTightening(true)
                .foregroundStyle(.secondary)
            Spacer()
            Text(cardioValue)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .allowsTightening(true)
                .foregroundStyle(cardioColor(cardioValue))
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(cardioColor(cardioValue).opacity(0.18), in: Capsule())
        }
    }

    @ViewBuilder
    private func rhythmRow(title: String, emoji: String, value: Float, previous: Float) -> some View {
        // Use explicit percent comparison and layout priorities to avoid unwanted text shrinking on Watch
        let currentPercent = Int((value * 100).rounded())
        let previousPercent = Int((previous * 100).rounded())
        let showArrow = currentPercent != previousPercent

        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Text(emoji)
                    .font(.subheadline)

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .allowsTightening(true)
                    .layoutPriority(0)

                Spacer()

                HStack(spacing: 4) {
                    Text("\(currentPercent)%")
                        .font(.system(.caption, design: .rounded).weight(.bold))
                        .lineLimit(1)
                        .layoutPriority(3)
                        .minimumScaleFactor(1.0)
                        .fixedSize()

                    if showArrow {
                        Image(systemName: value >= previous ? "arrow.up" : "arrow.down")
                            .font(.caption2.weight(.bold))
                            .layoutPriority(2)
                    }
                }
                .foregroundStyle(phaseColor(value))
                .monospacedDigit()
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .frame(minWidth: 64, alignment: .center)
                .fixedSize(horizontal: true, vertical: false)
                .background(phaseColor(value).opacity(0.16), in: Capsule())
            }
        }
    }

    private func phaseColor(_ value: Float) -> Color {
        if value < -0.05 {
            return .orange
        }
        if value <= 0.05 {
            return .red
        }
        return .green
    }

    private func cardioColor(_ level: String) -> Color {
        // If the value is numeric (VO2), map thresholds to colors.
        if let val = Double(level) {
            if val >= 40.0 { return .green }
            if val >= 36.0 { return .orange }
            return .red
        }
        // Legacy string labels fallback
        switch level {
        case "High":
            return .red
        case "Medium":
            return .orange
        default:
            return .green
        }
    }

    private func refreshAll() {
        let birthdayValue = groupDefaults?.string(forKey: "birthday") ?? "02/07/1979"
        calcRhythm(birthday: DateFormat().date(from: birthdayValue))
        // Fetch latest HealthKit metrics then refresh the view so the UI
        // reflects the newest VO2/HRV values stored in the app group.
        Task {
            print("[BenBio Watch] requesting HealthKit metrics...")
            let metrics = await fetchHealthMetricsAndStore()
            print("[BenBio Watch] fetched metrics: sdnn=\(metrics.sdnnMS ?? -1), vo2=\(metrics.vo2Max ?? -1)")
            refreshView()
        }
    }

    private func refreshView() {
        physical = groupDefaults?.float(forKey: "physical") ?? 0.0
        emotional = groupDefaults?.float(forKey: "emotional") ?? 0.0
        mental = groupDefaults?.float(forKey: "mental") ?? 0.0
        physical_1 = groupDefaults?.float(forKey: "physical_1") ?? 0.0
        emotional_1 = groupDefaults?.float(forKey: "emotional_1") ?? 0.0
        mental_1 = groupDefaults?.float(forKey: "mental_1") ?? 0.0
        if let vo2 = groupDefaults?.object(forKey: "vo2MaxValue") as? Double {
            cardioValue = String(Int(vo2.rounded()))
        } else {
            cardioValue = groupDefaults?.string(forKey: "rMSSDValue") ?? "0"
        }
    }
} //: ContentView

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
