//
//  StatsView.swift
//

import Charts
import DataProvider
import SwiftData
import SwiftUI

// MARK: - StatsView

struct StatsView: View {
	// MARK: Internal

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
					Button(action: { showGraph.toggle() }) {
						Image(systemName: showGraph ? "list.bullet" : "chart.bar")
					}.contentTransition(.symbolEffect(.replace))
				}

				ToolbarItem(placement: .navigationBarTrailing) {
					Menu("Sort") {
						Button("Date (Newest First)") {
							sortOrder = SortDescriptor(\Workout.date, order: .reverse)
						}
						Button("Date (Oldest First)") {
							sortOrder = SortDescriptor(\Workout.date, order: .forward)
						}
						Button("Count (Highest First)") {
							sortOrder = SortDescriptor(\Workout.count, order: .reverse)
						}
						Button("Duration (Longest First)") {
							sortOrder = SortDescriptor(\Workout.duration, order: .reverse)
						}
					}
				}
			}
		}
	}

	var filteredWorkouts: [Workout] {
		workouts.filter { $0.type == selectedWorkoutType }
	}

	func deleteWorkout(at offsets: IndexSet) {
		for index in offsets {
			modelContext.delete(filteredWorkouts[index])
		}
	}

	// MARK: Private

	@Environment(\.modelContext) private var modelContext
	@Query private var workouts: [Workout]
	@State private var sortOrder = SortDescriptor(\Workout.date, order: .reverse)
	@State private var selectedWorkoutType = "pushup"
	@State private var showGraph = true
}

// MARK: - WorkoutRow

struct WorkoutRow: View {
	let workout: Workout

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

// MARK: - WorkoutChart

struct WorkoutChart: View {
	let workouts: [Workout]

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
		.frame(maxWidth: .infinity, maxHeight: 200, alignment: .top)
		.chartPlotStyle { chartContent in
			chartContent
				.foregroundStyle(workouts.first?.type == "pushup" ? .green : .red)
				.background(Color.secondary.opacity(0.05))
		}
	}
}
