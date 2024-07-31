//
//  TrackerSelectionView.swift
//

import DataProvider
import SwiftData
import SwiftUI

struct TrackerSelectionView: View {
		// MARK: Internal

		var body: some View {
				NavigationStack {
						List {
								NavigationLink("Push-ups (Proximity)", destination: ProximityDetectorView())
								NavigationLink("Squats (Elevation)", destination: ElevationChangeView())
						}
						.navigationTitle("Select Exercise")
						.navigationBarTitleDisplayMode(.inline)
				}
		}

		// MARK: Private

		@Environment(\.modelContext) private var modelContext
		@Query private var workouts: [Workout]
}
