//
//  StatsView.swift
//

import Charts
import DataProvider
import SwiftData
import SwiftUI

// MARK: - StatsView

struct StatsView: View {
	// MARK: Private
	@Environment(\.modelContext) private var modelContext
	@Query(sort: [SortDescriptor(\Workout.date, order: .reverse)]) private var workouts: [Workout]
	@State private var sortOrder = SortDescriptor(\Workout.date, order: .reverse)
	@State private var selectedWorkoutType = "pushup"
	@State private var showGraph = true
	@State private var timeRange: TimeRange = .week
	
	private let cornerRadius: CGFloat = 12
	
	enum TimeRange: String, CaseIterable {
		case week = "Week"
		case month = "Month"
		case year = "Year"
		case all = "All"
		
		var days: Int {
			switch self {
			case .week: return 7
			case .month: return 30
			case .year: return 365
			case .all: return Int.max
			}
		}
	}

	var body: some View {
		NavigationView {
			ZStack {
				Color.Neumorphic.main.edgesIgnoringSafeArea(.all)
				
				VStack(spacing: 16) {
					// Exercise Type Selector
					Picker("Workout Type", selection: $selectedWorkoutType) {
						Text("Pushups").tag("pushup")
						Text("Squats").tag("squat")
					}
					.pickerStyle(.segmented)
					.padding()
					.softOuterShadow()
					
					// Stats Summary
					HStack(spacing: 12) {
						StatCard(title: "Total", value: "\(totalCount)")
						StatCard(title: "Average", value: String(format: "%.1f", averageCount))
						StatCard(title: "Best", value: "\(bestCount)")
					}
					.padding(.horizontal)
					
					// Time Range Selector
					ScrollView(.horizontal, showsIndicators: false) {
						HStack(spacing: 12) {
							ForEach(TimeRange.allCases, id: \.self) { range in
								Button(action: { timeRange = range }) {
									Text(range.rawValue)
										.foregroundColor(.primary)
								}
								.softButtonStyle(RoundedRectangle(cornerRadius: cornerRadius))
								.background(timeRange == range ? Color.Neumorphic.main.opacity(0.5) : Color.clear)
							}
						}
						.padding(.horizontal)
					}
					
					// View Toggle and Sort
					HStack {
						Button(action: { showGraph.toggle() }) {
							HStack {
								Image(systemName: showGraph ? "list.bullet" : "chart.bar")
								Text(showGraph ? "Show List" : "Show Chart")
							}
						}
						.softButtonStyle(RoundedRectangle(cornerRadius: cornerRadius))
						
						Spacer()
						
						Menu {
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
						} label: {
							HStack {
								Image(systemName: "arrow.up.arrow.down")
								Text("Sort")
							}
							.foregroundColor(.primary)
							.padding()
							.background(Color.Neumorphic.main)
							.clipShape(RoundedRectangle(cornerRadius: cornerRadius))
							.softOuterShadow()
						}
					}
					.padding(.horizontal)
					
					if showGraph {
						WorkoutChart(workouts: filteredAndSortedWorkouts, timeRange: timeRange)
							.softOuterShadow()
					} else {
						List {
							ForEach(filteredAndSortedWorkouts) { workout in
								WorkoutRow(workout: workout)
									.listRowBackground(Color.Neumorphic.main)
							}
							.onDelete(perform: deleteWorkout)
						}
						.scrollContentBackground(.hidden)
					}
				}
				.navigationTitle("Workout History")
			}
		}
	}
	
	var filteredAndSortedWorkouts: [Workout] {
		let filtered = workouts.filter { workout in
			workout.type == selectedWorkoutType &&
			workout.date > Calendar.current.date(byAdding: .day, value: -timeRange.days, to: Date())!
		}
		return filtered.sorted { first, second in
			switch sortOrder.keyPath {
			case \Workout.date:
				return sortOrder.order == .forward ? first.date < second.date : first.date > second.date
			case \Workout.count:
				return first.count > second.count
			case \Workout.duration:
				return first.duration > second.duration
			default:
				return false
			}
		}
	}
	
	var totalCount: Int {
		filteredAndSortedWorkouts.reduce(0) { $0 + $1.count }
	}
	
	var averageCount: Double {
		filteredAndSortedWorkouts.isEmpty ? 0 : Double(totalCount) / Double(filteredAndSortedWorkouts.count)
	}
	
	var bestCount: Int {
		filteredAndSortedWorkouts.max(by: { $0.count < $1.count })?.count ?? 0
	}
	
	func deleteWorkout(at offsets: IndexSet) {
		for index in offsets {
			modelContext.delete(filteredAndSortedWorkouts[index])
		}
		try? modelContext.save()
	}
}

struct StatCard: View {
	let title: String
	let value: String
	
	var body: some View {
		VStack(spacing: 8) {
			Text(title)
				.font(.caption)
				.foregroundColor(.secondary)
			Text(value)
				.font(.title2)
				.bold()
		}
		.frame(maxWidth: .infinity)
		.padding()
		.background(Color.Neumorphic.main)
		.softOuterShadow()
	}
}

struct WorkoutChart: View {
	let workouts: [Workout]
	let timeRange: StatsView.TimeRange
	
	var body: some View {
		Chart {
			ForEach(workouts) { workout in
				LineMark(
					x: .value("Date", workout.date),
					y: .value("Count", workout.count)
				)
				.foregroundStyle(workouts.first?.type == "pushup" ? .green : .red)
				
				AreaMark(
					x: .value("Date", workout.date),
					y: .value("Count", workout.count)
				)
				.foregroundStyle(
					.linearGradient(
						colors: [
							(workouts.first?.type == "pushup" ? Color.green : Color.red).opacity(0.3),
							Color.clear
						],
						startPoint: .top,
						endPoint: .bottom
					)
				)
				
				PointMark(
					x: .value("Date", workout.date),
					y: .value("Count", workout.count)
				)
				.foregroundStyle(workouts.first?.type == "pushup" ? .green : .red)
			}
		}
		.chartXAxis {
			AxisMarks(values: .stride(by: timeRange == .week ? 1 : 7)) { value in
				AxisGridLine()
				AxisValueLabel(format: .dateTime.weekday())
			}
		}
		.chartYAxis {
			AxisMarks { value in
				AxisGridLine()
				AxisValueLabel()
			}
		}
		.frame(height: 250)
		.padding()
		.background(Color.Neumorphic.main)
	}
}

struct WorkoutRow: View {
	let workout: Workout
	
	var body: some View {
		HStack(spacing: 16) {
			VStack(alignment: .leading, spacing: 4) {
				Text(workout.date.formatted(date: .abbreviated, time: .shortened))
					.font(.headline)
				Text("\(workout.count) \(workout.type == "pushup" ? "Pushups" : "Squats")")
					.font(.subheadline)
					.foregroundColor(.secondary)
			}
			
			Spacer()
			
			VStack(alignment: .trailing, spacing: 4) {
				Text(workout.duration.formatted())
					.font(.subheadline)
				Text("Duration")
					.font(.caption)
					.foregroundColor(.secondary)
			}
		}
		.padding()
		.background(Color.Neumorphic.main)
		.softOuterShadow()
	}
}
