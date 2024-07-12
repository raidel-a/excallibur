//  Created by Raidel Almeida on 6/28/24.
//
//  ContentView.swift
//  excallibur
//
//

import SwiftUI

@available(iOS 17.0, *)
struct ContentView: View {
    @StateObject private var viewModel = ProximityDetectorViewModel()
    
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
        .environmentObject(viewModel)
    }
}
