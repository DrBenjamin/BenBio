//
//  BenBio_Watch_Widget.swift
//  BenBio Watch Widget
//
//  Created by Benjamin Groß on 14/9/24.
//
import Foundation
import WidgetKit
import SwiftUI

// Load User defaults from Apple Watch App
nonisolated(unsafe) let defaults = UserDefaults(suiteName: "group.BenBioWatch.Data")

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

    func recommendations() -> [AppIntentRecommendation<ConfigurationAppIntent>] {
        // Create an array with all the preconfigured widgets to show.
        [AppIntentRecommendation(intent: ConfigurationAppIntent(), description: "BenBioWatch Widget")]
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct BenBio_Watch_WidgetEntryView : View {
    @State var biorthythm: String = (defaults!.string(forKey: "Biorhythm") ?? "0 • 0 • 0")
    @State var stresslevel: String = (defaults!.string(forKey: "rMSSDValue") ?? "Med.")
    @State var stress: Double = 0.3
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry
    var body: some View {
        switch widgetFamily {
        case .accessoryCorner:
            ZStack {
                if stresslevel == "High" {
                    // Error `Type '()' cannot confirm to 'View'
                    stress = 1.0
                } else {
                    if stresslevel == "Med." {
                        stress = 0.65
                    }
                }
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(
                            colors: [Color.white.opacity(0.1),
                                     Color.white.opacity(stress)]),
                        startPoint: .top,
                        endPoint: .bottom))
                    .font(.largeTitle)
                    .widgetLabel {
                        Text(biorthythm)
                    }
            }//:ZStack
            default:
                Text("?")
        }//:switch
    }//:View
}

@main
struct BenBio_Watch_Widget: Widget {
    let kind: String = "BenBio_Watch_Widget"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            BenBio_Watch_WidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .accessoryRectangular) {
    BenBio_Watch_Widget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley)
    SimpleEntry(date: .now, configuration: .starEyes)
}    
