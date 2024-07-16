//
//  WorkoutDataSource.swift
//  excallibur
//
//  Created by Raidel Almeida on 7/11/24.
//

import Foundation
import SwiftData

import SwiftUI

@MainActor
class WorkoutDataSource: ObservableObject {
    static let shared = WorkoutDataSource()
    
    private let modelContainer: ModelContainer
    let modelContext: ModelContext
    
    private init() {
        do {
            let schema = Schema([WorkoutData.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            modelContext = modelContainer.mainContext
            
                // Check if there's any existing data
            let existingWorkouts = try modelContext.fetch(FetchDescriptor<WorkoutData>())
            if existingWorkouts.isEmpty {
                loadSeedData()
            }
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }
    
    func addWorkout(_ workout: WorkoutData) {
        modelContext.insert(workout)
        saveContext()
    }
    
    func deleteWorkout(_ workout: WorkoutData) {
        modelContext.delete(workout)
        saveContext()
    }
    
    func updateWorkout(_ workout: WorkoutData) {
            // The context automatically tracks changes to managed objects
        saveContext()
    }
    
    func fetchWorkouts() -> [WorkoutData] {
        do {
            return try modelContext.fetch(FetchDescriptor<WorkoutData>())
        } catch {
            print("Failed to fetch workouts: \(error)")
            return []
        }
    }
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    func loadSeedData() {
        guard let url = Bundle.main.url(forResource: "seed_workouts", withExtension: "json") else {
            print("Failed to find seed_workouts.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let workouts = try JSONDecoder().decode([WorkoutData].self, from: data)
            
            for workout in workouts {
                modelContext.insert(workout)
            }
            
            try modelContext.save()
            print("Seed data loaded successfully")
        } catch {
            print("Failed to load seed data: \(error)")
        }
    }
}
