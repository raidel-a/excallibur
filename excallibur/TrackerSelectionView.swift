//  Created by Raidel Almeida on 6/30/24.
//
//  TrackerSelectionView.swift
//  excallibur
//
//

import SwiftUI

@available(iOS 17.0, *)
struct TrackerSelectionView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Push-ups (Proximity)", destination: ProximityDetectorView())
                NavigationLink("Squats (Elevation)", destination: ElevationChangeView())
            }
            .navigationTitle("Select Tracker")
        }
    }
}
