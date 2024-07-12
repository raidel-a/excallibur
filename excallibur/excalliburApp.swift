//  Created by Raidel Almeida on 6/28/24.
//
//  excalliburApp.swift
//  excallibur
//
//

import SwiftUI
import SwiftData

@main
struct excalliburApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: WorkoutData.self)
    }
}
