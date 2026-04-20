//
//  ContentView.swift
//  BenBio Mac App
//
//  Created by Gross, Benjamin on 25.02.24.
//

import SwiftUI

struct ContentView: View {
    @State private var physical: Float = groupDefaults?.float(forKey: "physical") ?? 0.0
    @State private var emotional: Float = groupDefaults?.float(forKey: "emotional") ?? 0.0
    @State private var mental: Float = groupDefaults?.float(forKey: "mental") ?? 0.0
    @State private var physicalYesterday: Float = groupDefaults?.float(forKey: "physical_1") ?? 0.0
    @State private var emotionalYesterday: Float = groupDefaults?.float(forKey: "emotional_1") ?? 0.0
    @State private var mentalYesterday: Float = groupDefaults?.float(forKey: "mental_1") ?? 0.0

    @State private var vo2MaxValue: Double = groupDefaults?.double(forKey: "vo2MaxValue") ?? 0.0
    @State private var sdnnValue: String = groupDefaults?.string(forKey: "SDNNValue") ?? "Low"
    @State private var rmssdValue: String = groupDefaults?.string(forKey: "rMSSDValue") ?? "Low"

    @State private var birthdayString: String = groupDefaults?.string(forKey: "birthday") ?? "02/07/1979"
    @State private var selectedBirthday: Date = Date()
    @State private var showBirthdayEditor: Bool = false

    init() {
        print("Mac App Start")
        if groupDefaults?.string(forKey: "birthday") == nil {
            groupDefaults?.set("02/07/1979", forKey: "birthday")
        }

        let storedBirthday = groupDefaults?.string(forKey: "birthday") ?? "02/07/1979"
        calcRhythm(birthday: DateFormat().date(from: storedBirthday))
    }

    var body: some View {
        ZStack {
            Image("BackGround")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    headerCard
                    rhythmCard
                    statusCard
                    adviceCard
                }
                .padding(16)
                .frame(maxWidth: 760)
            }
        }
        .onAppear {
            selectedBirthday = parseBirthday(birthdayString) ?? Date()
            refreshAll()
        }
        .sheet(isPresented: $showBirthdayEditor) {
            birthdayEditor
                .frame(width: 300, height: 360)
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("BenBio")
                    .font(.title2.weight(.bold))
                Spacer()
                Button {
                    selectedBirthday = parseBirthday(birthdayString) ?? Date()
                    showBirthdayEditor = true
                } label: {
                    Label("Edit Birthday", systemImage: "calendar")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }

            Text("Current: \(birthdayString)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
            .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    private var rhythmCard: some View {
        VStack(spacing: 10) {
            rhythmRow(title: "Physical", emoji: "💪", value: physical, previous: physicalYesterday)
            rhythmRow(title: "Emotional", emoji: "🧡", value: emotional, previous: emotionalYesterday)
            rhythmRow(title: "Mental", emoji: "🧠", value: mental, previous: mentalYesterday)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
            .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    private var statusCard: some View {
        VStack(spacing: 10) {
            statRow(label: "Cardiofitness", value: String(format: "%.1f", vo2MaxValue), color: .teal)
            statRow(label: "Stress (today)", value: sdnnValue, color: stressColor(sdnnValue))
            statRow(label: "Stress (now)", value: rmssdValue, color: stressColor(rmssdValue))
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
            .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    private var adviceCard: some View {
        HStack {
            Text("Advice")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(adviceEmoji())
                .font(.title2)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
            .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    private var birthdayEditor: some View {
        NavigationStack {
            VStack(spacing: 16) {
                DatePicker("Birthday", selection: $selectedBirthday, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()

                HStack(spacing: 10) {
                    Button("Cancel") {
                        showBirthdayEditor = false
                    }
                    .buttonStyle(.bordered)

                    Button("Apply Birthday") {
                        let newBirthday = DateFormat().string(from: selectedBirthday)
                        birthdayString = newBirthday
                        groupDefaults?.set(newBirthday, forKey: "birthday")
                        calcRhythm(birthday: DateFormat().date(from: newBirthday))
                        refreshAll()
                        showBirthdayEditor = false
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(18)
            .navigationTitle("Birthday")
        }
    }

    @ViewBuilder
    private func rhythmRow(title: String, emoji: String, value: Float, previous: Float) -> some View {
        let percent = abs(Int((value * 100).rounded()))
        let arrow = value >= previous ? "arrow.up" : "arrow.down"

        HStack(spacing: 10) {
            Text(emoji)
                .font(.title3)

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            HStack(spacing: 5) {
                Text("\(percent)%")
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                Image(systemName: arrow)
                    .font(.footnote.weight(.bold))
            }
            .foregroundStyle(phaseColor(value))
            .monospacedDigit()
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(phaseColor(value).opacity(0.15), in: Capsule())
        }
    }

    @ViewBuilder
    private func statRow(label: String, value: String, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(color.opacity(0.15), in: Capsule())
        }
    }

    private func phaseColor(_ value: Float) -> Color {
        if value < -0.05 { return .orange }
        if value <= 0.05 { return .red }
        return .green
    }

    private func stressColor(_ level: String) -> Color {
        switch level {
        case "High": return .red
        case "Medium": return .orange
        default: return .green
        }
    }

    private func adviceEmoji() -> String {
        if physical >= -0.05 && physical <= 0.05 || emotional >= -0.05 && emotional <= 0.05 || mental >= -0.05 && mental <= 0.05 {
            return "⚠️"
        }

        let sum = physical + emotional + mental
        if sum > 1 { return "🥳" }
        if sum < -1 { return "😴" }
        return "😃"
    }

    private func parseBirthday(_ value: String) -> Date? {
        DateFormat().date(from: value)
    }

    private func refreshAll() {
        birthdayString = groupDefaults?.string(forKey: "birthday") ?? "02/07/1979"
        calcRhythm(birthday: DateFormat().date(from: birthdayString))
        // Fetch latest HealthKit metrics so the Mac app mirrors iOS/watch.
        Task {
            print("[BenBio Mac] requesting HealthKit metrics...")
            let metrics = await fetchHealthMetricsAndStore()
            print("[BenBio Mac] fetched metrics: sdnn=\(metrics.sdnnMS ?? -1), vo2=\(metrics.vo2Max ?? -1)")
            refreshView()
        }
    }

    private func refreshView() {
        physical = groupDefaults?.float(forKey: "physical") ?? 0.0
        emotional = groupDefaults?.float(forKey: "emotional") ?? 0.0
        mental = groupDefaults?.float(forKey: "mental") ?? 0.0
        physicalYesterday = groupDefaults?.float(forKey: "physical_1") ?? 0.0
        emotionalYesterday = groupDefaults?.float(forKey: "emotional_1") ?? 0.0
        mentalYesterday = groupDefaults?.float(forKey: "mental_1") ?? 0.0
        vo2MaxValue = groupDefaults?.double(forKey: "vo2MaxValue") ?? 0.0
        sdnnValue = groupDefaults?.string(forKey: "SDNNValue") ?? "Low"
        rmssdValue = groupDefaults?.string(forKey: "rMSSDValue") ?? "Low"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
