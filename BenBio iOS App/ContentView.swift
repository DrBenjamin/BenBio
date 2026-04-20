//
//  ContentView.swift
//  BenBio iOS App
//
//  Created by Gross, Benjamin on 25.02.24.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

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
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    init() {
        print("iOS App Start")
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

            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: isPad ? 14 : 12) {
                        headerCard
                        dashboardContent
                    }
                    .frame(minHeight: proxy.size.height, alignment: .center)
                    .padding(.horizontal, isPad ? 24 : 16)
                    .padding(.vertical, 14)
                    .frame(maxWidth: 980, alignment: .center)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .dynamicTypeSize(isPad ? .xSmall ... .accessibility3 : .xSmall ... .accessibility1)
        .onAppear {
            selectedBirthday = parseBirthday(birthdayString) ?? Date()
            refreshAll()
            getCardiofitness()
            getHRVdata()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                refreshAll()
            }
        }
        .sheet(isPresented: $showBirthdayEditor) {
            birthdayEditor
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder
    private var dashboardContent: some View {
        if isWide {
            HStack(alignment: .top, spacing: 14) {
                VStack(spacing: 14) {
                    rhythmCard
                }
                .frame(maxWidth: .infinity, alignment: .top)

                VStack(spacing: 14) {
                    statusCard
                    adviceCard
                }
                .frame(maxWidth: .infinity, alignment: .top)
            }
        } else {
            VStack(spacing: 14) {
                rhythmCard
                statusCard
                adviceCard
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("BenBio")
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .allowsTightening(true)
                    .font((isCompact ? Font.headline : Font.title3).weight(.bold))
                Spacer()
                Button {
                    selectedBirthday = parseBirthday(birthdayString) ?? Date()
                    showBirthdayEditor = true
                } label: {
                    if isPhone {
                        Image(systemName: "calendar")
                            .imageScale(.medium)
                    } else {
                        Label("Birthday", systemImage: "calendar")
                            .labelStyle(.titleAndIcon)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .allowsTightening(true)
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(isCompact ? .mini : .small)
                .font((isCompact ? Font.footnote : Font.subheadline).weight(.semibold))
                .fixedSize(horizontal: true, vertical: false)
            }

            Text("Current: \(birthdayString)")
                .font(isCompact ? .caption : .footnote)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)
                .allowsTightening(true)
        }
        .padding(isPhone ? 10 : (isCompact ? 12 : 14))
        .frame(maxWidth: isPhone ? phoneCardMaxWidth : .infinity, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: isPhone ? .center : .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .clipped()
    }

    private var rhythmCard: some View {
        VStack(spacing: isCompact ? 8 : 10) {
            rhythmRow(title: "Physical", emoji: "💪", value: physical, previous: physicalYesterday)
            rhythmRow(title: "Emotional", emoji: "🧡", value: emotional, previous: emotionalYesterday)
            rhythmRow(title: "Mental", emoji: "🧠", value: mental, previous: mentalYesterday)
        }
        .padding(isPhone ? 10 : (isCompact ? 12 : 14))
        .frame(maxWidth: isPhone ? phoneCardMaxWidth : .infinity, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: isPhone ? .center : .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .clipped()
    }

    private var statusCard: some View {
        VStack(spacing: isCompact ? 8 : 10) {
            statRow(label: isCompact ? "Cardio" : "Cardiofitness", value: String(format: "%.1f", vo2MaxValue), color: .teal)
            statRow(label: isCompact ? "Stress day" : "Stress (today)", value: sdnnValue, color: stressColor(sdnnValue))
            statRow(label: isCompact ? "Stress now" : "Stress (now)", value: rmssdValue, color: stressColor(rmssdValue))
        }
        .padding(isPhone ? 10 : (isCompact ? 12 : 14))
        .frame(maxWidth: isPhone ? phoneCardMaxWidth : .infinity, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: isPhone ? .center : .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .clipped()
    }

    private var adviceCard: some View {
        Group {
            if isPhone {
                VStack(spacing: 6) {
                    Text("Advice")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Text(adviceEmoji())
                        .font(.title3)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            } else {
                HStack {
                    Text("Advice")
                        .font(isCompact ? .footnote : .subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(adviceEmoji())
                        .font(isCompact ? .title3 : .title3)
                }
            }
        }
        .padding(isPhone ? 10 : (isCompact ? 12 : 14))
        .frame(maxWidth: isPhone ? phoneCardMaxWidth : .infinity, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: isPhone ? .center : .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .clipped()
    }

    private var birthdayEditor: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    DatePicker("Birthday", selection: $selectedBirthday, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .labelsHidden()

                    Button("Apply Birthday") {
                        let newBirthday = DateFormat().string(from: selectedBirthday)
                        birthdayString = newBirthday
                        groupDefaults?.set(newBirthday, forKey: "birthday")
                        calcRhythm(birthday: DateFormat().date(from: newBirthday))
                        refreshAll()
                        showBirthdayEditor = false
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                }
                .padding()
            }
            .navigationTitle("Birthday")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { showBirthdayEditor = false }
                }
            }
        }
    }

    @ViewBuilder
    private func rhythmRow(title: String, emoji: String, value: Float, previous: Float) -> some View {
        let currentPercent = Int((value * 100).rounded())
        let previousPercent = Int((previous * 100).rounded())
        let showArrow = currentPercent != previousPercent

        Group {
            if isPhone {
                VStack(spacing: 5) {
                    HStack(spacing: 6) {
                        Text(emoji)
                            .font(.headline)
                        Text(title)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .allowsTightening(true)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)

                    HStack(spacing: 5) {
                        Text("\(currentPercent)%")
                            .font(.system(.footnote, design: .rounded).weight(.bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .allowsTightening(true)
                            .layoutPriority(2)
                        if showArrow {
                            Image(systemName: value >= previous ? "arrow.up" : "arrow.down")
                                .font(Font.caption.weight(.bold))
                                .layoutPriority(1)
                        }
                    }
                    .foregroundStyle(phaseColor(value))
                    .monospacedDigit()
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .frame(minWidth: 58, alignment: .center)
                    .fixedSize(horizontal: false, vertical: true)
                    .background(phaseColor(value).opacity(0.15), in: Capsule())
                }
            } else {
                HStack(spacing: isCompact ? 5 : 8) {
                    Text(emoji)
                        .font(isCompact ? .headline : .title3)

                    Text(title)
                        .font(isCompact ? .footnote : .subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .allowsTightening(true)

                    Spacer()

                    HStack(spacing: 5) {
                        Text("\(currentPercent)%")
                            .font(.system(isCompact ? .footnote : .subheadline, design: .rounded).weight(.bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .allowsTightening(true)
                            .layoutPriority(2)
                        if showArrow {
                            Image(systemName: value >= previous ? "arrow.up" : "arrow.down")
                                .font((isCompact ? Font.caption : Font.footnote).weight(.bold))
                                .layoutPriority(1)
                        }
                    }
                    .foregroundStyle(phaseColor(value))
                    .monospacedDigit()
                    .padding(.horizontal, isCompact ? 6 : 10)
                    .padding(.vertical, isCompact ? 4 : 6)
                    .frame(minWidth: isCompact ? 62 : 72, alignment: .center)
                    .fixedSize(horizontal: false, vertical: true)
                    .background(phaseColor(value).opacity(0.15), in: Capsule())
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: isPhone ? .center : .leading)
        .clipped()
    }

    @ViewBuilder
    private func statRow(label: String, value: String, color: Color) -> some View {
        Group {
            if isPhone {
                VStack(spacing: 5) {
                    Text(label)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                        .multilineTextAlignment(.center)
                        .truncationMode(.tail)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(value)
                        .font(Font.footnote.weight(.semibold))
                        .foregroundStyle(color)
                        .layoutPriority(1)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .allowsTightening(true)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(color.opacity(0.15), in: Capsule())
                }
                .frame(maxWidth: .infinity, alignment: .center)
            } else {
                HStack {
                    Text(label)
                        .font(isCompact ? .footnote : .subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(isCompact ? 2 : 1)
                        .minimumScaleFactor(0.7)
                        .multilineTextAlignment(.leading)
                        .truncationMode(.tail)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    Text(value)
                        .font((isCompact ? Font.footnote : Font.subheadline).weight(.semibold))
                        .foregroundStyle(color)
                        .layoutPriority(1)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .allowsTightening(true)
                        .padding(.horizontal, isCompact ? 6 : 10)
                        .padding(.vertical, isCompact ? 3 : 4)
                        .background(color.opacity(0.15), in: Capsule())
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: isPhone ? .center : .leading)
        .clipped()
    }

    private var isCompact: Bool {
        horizontalSizeClass != .regular
    }

    private var isWide: Bool {
        horizontalSizeClass == .regular
    }

    private var isPad: Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad
        #else
        return false
        #endif
    }

    private var isPhone: Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .phone
        #else
        return false
        #endif
    }

    private var phoneCardMaxWidth: CGFloat {
        #if os(iOS)
        // Prefer a conservative max width that works across iPhone sizes without using UIScreen.main
        // This avoids deprecation warnings on iOS 26 where UIScreen.main is discouraged.
        return 360
        #else
        return 360
        #endif
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
        let birthdayString = groupDefaults?.string(forKey: "birthday") ?? "02/07/1979"
        calcRhythm(birthday: DateFormat().date(from: birthdayString))
        refreshView()
        // Fetch latest HealthKit metrics then refresh the view so the UI
        // reflects the newest VO2/HRV values stored in the app group.
        Task {
            print("[BenBio iOS] requesting HealthKit metrics...")
            let metrics = await fetchHealthMetricsAndStore()
            print("[BenBio iOS] fetched metrics: sdnn=\(metrics.sdnnMS ?? -1), vo2=\(metrics.vo2Max ?? -1)")
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

