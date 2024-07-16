    //
    //  StatsView.swift
    //  excallibur
    //
    //  Created by Raidel Almeida on 6/30/24.
    //

import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
        //    @Query private var workouts: [WorkoutData]
    @State private var sortOrder: SortDescriptor<WorkoutData> = SortDescriptor(\WorkoutData.date, order: .reverse)
    @State private var selectedWorkoutType = "pushup"
    @State private var showGraph = true
    @Query(sort: [SortDescriptor(\WorkoutData.date, order: .reverse)]) private var workouts: [WorkoutData]
    
    
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Workout Type", selection: $selectedWorkoutType) {
                    Text("Pushups").tag("pushup")
                    Text("Squats").tag("squat")
                }
                .pickerStyle(.segmented)
                .padding()
                
                
                if showGraph {
                    WorkoutChart(workouts: filteredWorkouts)
                } else {
                    List {
                        ForEach(filteredWorkouts) { workout in
                            WorkoutRow(workout: workout)
                        }
                        .onDelete(perform: deleteWorkout)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationTitle("Workout History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showGraph.toggle()
                    }) {
                        Image(systemName: showGraph ? "list.bullet" : "chart.bar")
                    }.contentTransition(.symbolEffect(.replace))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
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
        }
    }
    
    var filteredWorkouts: [WorkoutData] {
        workouts.filter { $0.type == selectedWorkoutType }
    }
    
    func deleteWorkout(at offsets: IndexSet) {
        for index in offsets {
            let workout = workouts[index]
            WorkoutDataSource.shared.deleteWorkout(workout)
        }
    }
}

extension TimeInterval {
    func formatted() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: self) ?? ""
    }
}

struct WorkoutRow: View {
    let workout: WorkoutData
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text(workout.date, style: .date)
                    .font(.headline)
                Text("Duration: \(workout.duration.formatted())")
            }
            Spacer()
            Text("\(workout.type == "pushup" ? "Pushups" : "Squats"): \(workout.count)")
        }
    }
}

struct WorkoutChart: View {
    let workouts: [WorkoutData]
    
    var body: some View {
        Chart {
            ForEach(workouts) { workout in
                PointMark(
                    x: .value("Date", workout.date),
                    y: .value("Count", workout.count)
                )
            }
        }
        .aspectRatio(2, contentMode: .fit)
        .padding()
        .frame(maxWidth: .infinity, maxHeight
               : 200, alignment: .top)
        .chartPlotStyle { chartContent in
            chartContent
                .foregroundStyle(workouts.first?.type == "pushup" ? .green : .red)
                .background(Color.secondary.opacity(0.05))
        }
    }
}

extension WorkoutData {
    static func sampleData() -> [WorkoutData] {
        let calendar = Calendar.current
        let now = Date()
        var workoutDataArray = [WorkoutData]()
        
        for i in 20...30 {
            let date = calendar.date(byAdding: .day, value: -i, to: now)!
            let duration = Int.random(in: 200...600)
            let count = Int.random(in: 20...70)
            let type = Bool.random() ? "pushup" : "squat"
            
            workoutDataArray.append(WorkoutData(id: UUID(), date:date, duration:TimeInterval(duration), count: count, type: type))
        }
        return workoutDataArray
        
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
            .modelContainer(for: WorkoutData.self, inMemory: true) { result in
                switch result {
                    case .success(let container):
                        for workout in WorkoutData.sampleData() {
                            container.mainContext.insert(workout)
                        }
                    case .failure(let error):
                        fatalError("Failed to create model container: \(error.localizedDescription)")
                }
            }
    }
}

