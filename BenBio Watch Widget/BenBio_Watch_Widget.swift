//
//  BenBio_Watch_Widget.swift
//  BenBio Watch Widget
//
//  Created by Benjamin Groß on 14/9/24.
//
import Foundation
import WidgetKit
import SwiftUI

enum CornerVariant {
    case physical
    case emotional
    case mental
    case cardio
}

enum FamilyVariant {
    case corner
    case circular
}

struct BenBio_Watch_WidgetEntryView : View {
    var entry: Provider.Entry
    let variant: CornerVariant
    var family: FamilyVariant = .corner
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .accessoryCorner:
            ZStack { }
                .widgetLabel {
                    Label(labelText, systemImage: symbolName)
                        .font(.system(size: 14, weight: .semibold))
                        .monospacedDigit()
                }
#if os(watchOS)
                .widgetAccentable()
#endif
        case .accessoryCircular:
            ZStack {
                Circle().fill(.clear)
                VStack(spacing: 2) {
                    Image(systemName: symbolName)
                        .font(.system(size: 13, weight: .semibold))
                    Text(centerText)
                        .font(.system(size: 12, weight: .semibold))
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                        .monospacedDigit()
                }
                .padding(4)
            }
#if os(watchOS)
            .widgetAccentable()
#endif
        case .accessoryRectangular:
            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    // Top row: Physical • Emotional
                    HStack(spacing: 4) {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 10, weight: .semibold))
                        Text(entry.physicalText)
                            .font(.system(size: 13, weight: .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .monospacedDigit()
                    }
                    Spacer(minLength: 8)
                    HStack(spacing: 4) {
                        Image(systemName: "heart")
                            .font(.system(size: 10, weight: .semibold))
                        Text(entry.emotionalText)
                            .font(.system(size: 13, weight: .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .monospacedDigit()
                    }
                }
                HStack(spacing: 8) {
                    // Bottom row: Mental • Cardio
                    HStack(spacing: 4) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 10, weight: .semibold))
                        Text(entry.mentalText)
                            .font(.system(size: 13, weight: .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .monospacedDigit()
                    }
                    Spacer(minLength: 8)
                    HStack(spacing: 4) {
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 10, weight: .semibold))
                        Text(entry.vo2Text ?? entry.stressLevel)
                            .font(.system(size: 13, weight: .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .monospacedDigit()
                    }
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 6)
#if os(watchOS)
            .widgetAccentable()
#endif
        default:
            Text("?")
        }//:switch
    }//:View

    private var labelText: String {
        switch variant {
        case .physical:
            return entry.physicalText
        case .emotional:
            return entry.emotionalText
        case .mental:
            return entry.mentalText
        case .cardio:
            // For the corner complication prefer showing VO2 if available,
            // otherwise fall back to the legacy stress label.
            return entry.vo2Text ?? entry.stressLevel
        }
    }

    private var symbolName: String {
        switch variant {
        case .physical:
            return "figure.strengthtraining.traditional"
        case .emotional:
            return "heart"
        case .mental:
            return "brain.head.profile"
        case .cardio:
            // Circular complication: use a plain heart symbol.
            // Other widget views: use an ECG-like waveform to imply sinus/HR.
            if widgetFamily == .accessoryCircular {
                return "heart"
            } else {
                return "waveform.path.ecg"
            }
        }
    }

    private var centerText: String {
        switch variant {
        case .physical:
            return entry.physicalText
        case .emotional:
            return entry.emotionalText
        case .mental:
            return entry.mentalText
        case .cardio:
            // For the circular complication show VO2 (cardio) rounded
            // integer if available; otherwise fall back to legacy label.
            if widgetFamily == .accessoryCircular {
                return entry.vo2Text ?? entry.stressLevel
            }
            return entry.stressLevel
        }
    }

    private var valueText: String {
        switch variant {
        case .physical:
            return entry.physicalText
        case .emotional:
            return entry.emotionalText
        case .mental:
            return entry.mentalText
        case .cardio:
            return entry.stressLevel
        }
    }
}//:View

struct Provider: TimelineProvider {
    private let appGroupID = "group.org.seriousbenentertainment.BenBioWatch.Data"

    func placeholder(in context: Context) -> SimpleEntry {
        makeEntry(at: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = makeEntry(at: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let currentDate = Date()
        let nextMidnight = Calendar.current.nextDate(
            after: currentDate,
            matching: DateComponents(hour: 0, minute: 0, second: 5),
            matchingPolicy: .nextTime,
            direction: .forward
        ) ?? Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!

        let entries = [
            makeEntry(at: currentDate),
            makeEntry(at: nextMidnight)
        ]

        // Ask WidgetKit for a fresh timeline shortly after the next rollover.
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: nextMidnight)!
        let timeline = Timeline(entries: entries, policy: .after(refreshDate))

        completion(timeline)
    }

    private func makeEntry(at date: Date) -> SimpleEntry {
        let defaults = UserDefaults(suiteName: appGroupID)
        let stressLevel = defaults?.string(forKey: "rMSSDValue") ?? "Low"
        var birthdayString = defaults?.string(forKey: "birthday")
        if birthdayString == nil {
            let fallback = "02/07/1979"
            defaults?.set(fallback, forKey: "birthday")
            birthdayString = fallback
        }
        let adviceFromDefaults = defaults?.string(forKey: "Advice") ?? defaults?.string(forKey: "advice")

        let biorhythm: String
        if let birthday = parseBirthday(from: birthdayString) {
            biorhythm = computeBiorhythm(for: date, birthday: birthday)
        } else {
            biorhythm = defaults?.string(forKey: "Biorhythm") ?? "0 • 0 • 0"
        }

        let (physical, emotional, mental): (Int, Int, Int)
        if let birthday = parseBirthday(from: birthdayString) {
            let values = computeBiorhythmTriplet(for: date, birthday: birthday)
            physical = values.0
            emotional = values.1
            mental = values.2
        } else {
            // Try to parse stored string "Biorhythm" like "12 • -5 • 33"
            let parts = (defaults?.string(forKey: "Biorhythm") ?? "0 • 0 • 0").split(separator: "•").map { $0.trimmingCharacters(in: .whitespaces) }
            func intAt(_ i: Int) -> Int { i < parts.count ? (Int(parts[i]) ?? 0) : 0 }
            physical = intAt(0)
            emotional = intAt(1)
            mental = intAt(2)
        }

        let physicalText = "\(physical)"
        let emotionalText = "\(emotional)"
        let mentalText = "\(mental)"

        let stress: Double
        if stressLevel == "High" {
            stress = 1.0
        } else if stressLevel == "Med." {
            stress = 0.5
        } else {
            stress = 0.3
        }

        let advice = adviceFromDefaults ?? defaultAdvice(for: stressLevel)

        // Read VO2 (cardio) from group defaults if present. Use
        // `object(forKey:)` to detect absence vs a zero value.
        let vo2Obj = defaults?.object(forKey: "vo2MaxValue")
        let vo2Text: String?
        if let v = vo2Obj as? Double {
            vo2Text = String(Int(v.rounded()))
        } else {
            vo2Text = nil
        }

        return SimpleEntry(
            date: date,
            biorhythm: biorhythm,
            stressLevel: stressLevel,
            stress: stress,
            advice: advice,
            physicalText: physicalText,
            emotionalText: emotionalText,
            mentalText: mentalText,
            vo2Text: vo2Text
        )
    }

    private func parseBirthday(from value: String?) -> Date? {
        guard let value else {
            return nil
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: value)
    }

    private func computeBiorhythm(for date: Date, birthday: Date) -> String {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let startOfBirthday = Calendar.current.startOfDay(for: birthday)
        let dayDelta = Calendar.current.dateComponents([.day], from: startOfBirthday, to: startOfDay).day ?? 0

        func rhythm(_ cycle: Double) -> Int {
            let value = sin(2 * Double.pi * Double(dayDelta) / cycle)
            return Int((value * 100).rounded())
        }

        let physical = rhythm(23)
        let emotional = rhythm(28)
        let mental = rhythm(33)
        return "\(physical) • \(emotional) • \(mental)"
    }

    private func computeBiorhythmTriplet(for date: Date, birthday: Date) -> (Int, Int, Int) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let startOfBirthday = Calendar.current.startOfDay(for: birthday)
        let dayDelta = Calendar.current.dateComponents([.day], from: startOfBirthday, to: startOfDay).day ?? 0

        func rhythm(_ cycle: Double) -> Int {
            let value = sin(2 * Double.pi * Double(dayDelta) / cycle)
            return Int((value * 100).rounded())
        }

        return (rhythm(23), rhythm(28), rhythm(33))
    }
    
    private func defaultAdvice(for stressLevel: String) -> String {
        switch stressLevel {
        case "High":
            return "Recover"
        case "Med.", "Medium":
            return "Balance"
        default:
            return "Go for it"
        }
    }

    func recommendations() -> [AppIntentRecommendation<ConfigurationAppIntent>] {
        [AppIntentRecommendation(intent: ConfigurationAppIntent(), description: "BenBioWatch Widget")]
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let biorhythm: String
    let stressLevel: String
    let stress: Double
    let advice: String
    let physicalText: String
    let emotionalText: String
    let mentalText: String
    // Optional rounded VO2 value for circular complication display
    let vo2Text: String?
}

struct BenBio_Physical_Corner: Widget {
    let kind: String = "BenBio_Physical_Corner"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            BenBio_Watch_WidgetEntryView(entry: entry, variant: .physical, family: .corner)
                .containerBackground(.fill.tertiary, for: .widget)
                .background(Image("BackGround").resizable().scaledToFill().opacity(0.25))
                .clipped()
        }
        .supportedFamilies([.accessoryCorner, .accessoryCircular])
        .configurationDisplayName("BenBio — Physical")
        .description("Physical biorhythm for accessory corner. Supports circular on compatible faces.")
    }
}

struct BenBio_Emotional_Corner: Widget {
    let kind: String = "BenBio_Emotional_Corner"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            BenBio_Watch_WidgetEntryView(entry: entry, variant: .emotional, family: .corner)
                .containerBackground(.fill.tertiary, for: .widget)
                .background(Image("BackGround").resizable().scaledToFill().opacity(0.25))
                .clipped()
        }
        .supportedFamilies([.accessoryCorner, .accessoryCircular])
        .configurationDisplayName("BenBio — Emotional")
        .description("Emotional biorhythm for accessory corner. Supports circular on compatible faces.")
    }
}

struct BenBio_Mental_Corner: Widget {
    let kind: String = "BenBio_Mental_Corner"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            BenBio_Watch_WidgetEntryView(entry: entry, variant: .mental, family: .corner)
                .containerBackground(.fill.tertiary, for: .widget)
                .background(Image("BackGround").resizable().scaledToFill().opacity(0.25))
                .clipped()
        }
        .supportedFamilies([.accessoryCorner, .accessoryCircular])
        .configurationDisplayName("BenBio — Mental")
        .description("Mental biorhythm for accessory corner. Supports circular on compatible faces.")
    }
}

struct BenBio_Cardio_Corner: Widget {
    let kind: String = "BenBio_Cardio_Corner"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            BenBio_Watch_WidgetEntryView(entry: entry, variant: .cardio, family: .corner)
                .containerBackground(.fill.tertiary, for: .widget)
                .background(Image("BackGround").resizable().scaledToFill().opacity(0.25))
                .clipped()
        }
        .supportedFamilies([.accessoryCorner, .accessoryCircular])
        .configurationDisplayName("BenBio — Cardio")
        .description("Cardio fitness (VO2) for accessory corner. Shows rounded VO2 in circular complication on compatible faces.")
    }
}

struct BenBio_Rectangular_All: Widget {
    let kind: String = "BenBio_Rectangular_All"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            // The entry view adapts its layout by family; variant is irrelevant for rectangular.
            BenBio_Watch_WidgetEntryView(entry: entry, variant: .physical, family: .corner)
                .containerBackground(.fill.tertiary, for: .widget)
                .background(Image("BackGround").resizable().scaledToFill().opacity(0.25))
                .clipped()
        }
        .supportedFamilies([.accessoryRectangular])
        .configurationDisplayName("BenBio — All (2×2)")
        .description("Shows Physical, Emotional, Mental, and Cardio in a 2×2 grid for the rectangular widget.")
    }
}

@main
struct BenBio_Watch_WidgetBundle: WidgetBundle {
    var body: some Widget {
        BenBio_Physical_Corner()
        BenBio_Emotional_Corner()
        BenBio_Mental_Corner()
        BenBio_Cardio_Corner()
        BenBio_Rectangular_All()
    }
}
