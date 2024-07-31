//
//  TrackerWidget_Extension.swift
//  TrackerWidget-Extension
//
//  Created by Raidel Almeida on 7/25/24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
	func placeholder(in context: Context) -> GoalEntry {
		GoalEntry(date: Date(), goal: 100, current: 0)
	}
	
	func getSnapshot(in context: Context, completion: @escaping (GoalEntry) -> ()) {
		let entry = GoalEntry(date: Date(), goal: getUserDefaultsGoal(), current: 0)
		completion(entry)
	}
	
	func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
		let currentDate = Date()
		let entry = GoalEntry(date: currentDate, goal: getUserDefaultsGoal(), current: 0)
		let timeline = Timeline(entries: [entry], policy: .atEnd)
		completion(timeline)
	}
	
	private func getUserDefaultsGoal() -> Int {
		return UserDefaults(suiteName: "group.com.yourapp.widgetsharing")?.integer(forKey: "Push-Up") ?? 100
	}
}

struct GoalEntry: TimelineEntry {
	let date: Date
	let goal: Int
	let current: Int
}

struct TrackerWidget_ExtensionEntryView : View {
	var entry: Provider.Entry
	
	var body: some View {
		VStack {
			Text("Daily Goal")
				.font(.caption)
			Text("\(entry.goal)")
				.font(.title)
			Text("Push-ups")
				.font(.caption)
		}
	}
}

struct TrackerWidget_Extension: Widget {
	let kind: String = "TrackerWidget_Extension"
	
	var body: some WidgetConfiguration {
		StaticConfiguration(kind: kind, provider: Provider()) { entry in
			if #available(iOS 17.0, *) {
				TrackerWidget_ExtensionEntryView(entry: entry)
					.containerBackground(.fill.tertiary, for: .widget)
			} else {
				TrackerWidget_ExtensionEntryView(entry: entry)
					.padding()
					.background()
			}
		}
		.configurationDisplayName("Push-up Goal")
		.description("Displays your daily push-up goal.")
		.supportedFamilies([.accessoryCircular, .systemSmall])
	}
}

#Preview(as: .accessoryCircular) {
	TrackerWidget_Extension()
} timeline: {
	GoalEntry(date: Date(), goal: 100, current: 0)
}
