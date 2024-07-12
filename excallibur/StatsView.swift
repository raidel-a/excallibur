//
//  StatsView.swift
//  excallibur
//
//  Created by Raidel Almeida on 6/30/24.
//

import SwiftUI
import SwiftData

struct StatsView: View {
    @State private var sortOrder: SortDescriptor<WorkoutData> = SortDescriptor(\WorkoutData.date, order: .reverse)
    @State private var workoutType: WorkoutType = .pushup
    @Environment(\.modelContext) private var modelContext
    @State private var refreshID = UUID()
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Workout Type", selection: $workoutType) {
                    Text("Pushups").tag(WorkoutType.pushup)
                    Text("Squats").tag(WorkoutType.squat)
                }
                .pickerStyle(.segmented)
                .padding()
                
                WorkoutListView(workoutType: workoutType, sortOrder: sortOrder)
                    .id(refreshID)
                
                Button("Add Sample Data") {
                    addSampleData()
                }
                .padding()
                
                Button("Refresh Data") {
                    refreshData()
                }
                .padding()
            }
            .navigationTitle("Workout History")
            .toolbar {
                Menu("Sort") {
                    Button("Date (Newest First)") {
                        sortOrder = SortDescriptor(\WorkoutData.date, order: .reverse)
                    }
                    Button("Date (Oldest First)") {
                        sortOrder = SortDescriptor(\WorkoutData.date, order: .forward)
                    }
                    Button("Count (Highest First)") {
                        sortOrder = SortDescriptor(\WorkoutData.count, order: .reverse)
                    }
                    Button("Duration (Longest First)") {
                        sortOrder = SortDescriptor(\WorkoutData.duration, order: .reverse)
                    }
                }
            }
        }
        .onAppear {
            refreshData()
        }
    }
    
    private func addSampleData() {
        let pushupWorkout = WorkoutData(date: Date(), duration: 300, count: 50, type: .pushup)
        let squatWorkout = WorkoutData(date: Date().addingTimeInterval(-86400), duration: 400, count: 30, type: .squat)
        
        modelContext.insert(pushupWorkout)
        modelContext.insert(squatWorkout)
        
        do {
            try modelContext.save()
            print("Sample data added successfully")
            refreshData()
        } catch {
            print("Failed to save sample data: \(error)")
        }
    }
    
    private func refreshData() {
        refreshID = UUID()
    }
}

struct WorkoutListView: View {
    @Query private var workouts: [WorkoutData]
    @State private var debugMessage: String = ""
    
    init(workoutType: WorkoutType, sortOrder: SortDescriptor<WorkoutData>) {
        _workouts = Query(filter: #Predicate<WorkoutData> { workout in
            workout.type == workoutType
        }, sort: [sortOrder])
    }
    
    var body: some View {
        VStack {
            Text(debugMessage)
                .font(.caption)
                .foregroundColor(.red)
            
            if workouts.isEmpty {
                Text("No workouts found")
                    .foregroundColor(.secondary)
            } else {
                List {
                    ForEach(workouts) { workout in
                        VStack(alignment: .leading) {
                            Text(workout.date, style: .date)
                                .font(.headline)
                            Text("Duration: \(formatDuration(workout.duration))")
                            Text("\(workout.type == .pushup ? "Pushups" : "Squats"): \(workout.count)")
                        }
                    }
                }
            }
        }
        .onAppear {
            debugQuery()
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? ""
    }
    
    private func debugQuery() {
        debugMessage = "Total workouts: \(workouts.count)"
        print("Debug: \(debugMessage)")
        for workout in workouts {
            print("Workout: date=\(workout.date), type=\(workout.type.rawValue), count=\(workout.count)")
        }
    }
}
