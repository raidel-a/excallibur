//
//  TabBarView.swift
//

import SwiftUI

struct TabBarView: View {
	var body: some View {
		TabView {
			TrackerSelectionView()
				.tabItem {
					Label("Trackers", systemImage: "figure.run")
				}

			StatsView()
				.tabItem {
					Label("Stats", systemImage: "chart.bar")
				}

			SettingsView()
				.tabItem {
					Label("Profile", systemImage: "person.circle")
				}
		}
	}
}
