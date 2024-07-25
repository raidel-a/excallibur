//  Created by Raidel Almeida on 6/30/24.
//
//  TrackerSelectionView.swift
//  excallibur
//
//

import SwiftUI

// MARK: - TrackerSelectionView

@available(iOS 17.0, *)
struct TrackerSelectionView: View {
	var body: some View {
		NavigationStack {
			List {
				NavigationLink("Push-ups (Proximity)", destination: ProximityDetectorView())
				NavigationLink("Squats (Elevation)", destination: ElevationChangeView())
			}
			Grid {
				
			}
			.navigationTitle("Select Exercise")
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}

// MARK: - TrackerSelectionView_Previews

@available(iOS 17.0, *)
struct TrackerSelectionView_Previews: PreviewProvider {
	static var previews: some View {
		TrackerSelectionView()
	}
}
