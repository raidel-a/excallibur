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
    @StateObject private var dataSource = WorkoutDataSource.shared

    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataSource)
        }
        .modelContainer(for: WorkoutData.self) 
//        { result in
//            switch result {
//                case .success(let container):
//                    print("Successfully created ModelContainer")
//                case .failure(let error):
//                    print("Failed to create ModelContainer: \(error)")
//                        // Handle the error, possibly by resetting the store
//                    ModelContainer.resetStore(for: WorkoutData.self)
//            }
//        }
    }
}
