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

struct BenBio_Watch_WidgetEntryView : View {
    var entry: Provider.Entry
    @State var stress: Double = 0.3
    @State var biorthythm: String = (defaults!.string(forKey: "Biorhythm") ?? "0 • 0 • 0")
    @State var stresslevel: String = (defaults!.string(forKey: "rMSSDValue") ?? "Low")
    @Environment(\.widgetFamily) var widgetFamily
    var body: some View {
        switch widgetFamily {
        case .accessoryCorner:
            ZStack {
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
                    .onAppear {
                        updateValues()
                    }
            }//:ZStack
            .onAppear {
                updateValues()
            }
            default:
                Text("?")
        }//:switch
    }//:View
    func updateValues() {
        biorthythm = (defaults!.string(forKey: "Biorhythm") ?? "0 • 0 • 0")
        stresslevel = (defaults!.string(forKey: "rMSSDValue") ?? "Low")
        print(stresslevel)
        if stresslevel == "High" {
            stress = 1.0
        } else if stresslevel == "Med." {
            stress = 0.5
        } else {
            stress = 0.3
        }
    }
}//:View

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let currentDate = Date()
        let entry = SimpleEntry(date: currentDate)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

    func recommendations() -> [AppIntentRecommendation<ConfigurationAppIntent>] {
        [AppIntentRecommendation(intent: ConfigurationAppIntent(), description: "BenBioWatch Widget")]
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

@main
struct BenBio_Watch_Widget: Widget {
    let kind: String = "BenBio_Watch_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            BenBio_Watch_WidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("BenBio Watch Widget")
        .description("The BenBio Watch Widget")
    }
}
