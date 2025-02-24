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
  @State private var showGraph = false
  @State private var timeRange: TimeRange = .week
  @State private var isSelectedRange: Bool = false

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
          // Picker("Workout Type", selection: $selectedWorkoutType) {
          // 	Text("Pushups").tag("pushup")
          // 	Text("Squats").tag("squat")
          // }
          // .pickerStyle(.segmented)
          // .padding()
          // .softOuterShadow()

          // Stats Summary
          HStack(spacing: 15) {
            StatCard(title: "Total", value: "\(totalCount)")
            StatCard(title: "Average", value: String(format: "%.1f", averageCount))
            StatCard(title: "Best", value: "\(bestCount)")
          }
          .padding(.horizontal)
          //          .frame(height: 100)

          // Time Range Selector
          HStack(spacing: 12) {
            ForEach(TimeRange.allCases, id: \.self) { range in
              Button(action: { timeRange = range }) {
                Text(range.rawValue)
                  .foregroundColor(.primary)
                  .frame(maxWidth: .infinity)
                  .frame(height: 40)
                  .background(
                    ZStack {
                      if timeRange == range {
                        RoundedRectangle(cornerRadius: cornerRadius)
                          .fill(Color.Neumorphic.main)
                          .softInnerShadow(
                            RoundedRectangle(cornerRadius: cornerRadius), spread: 0.15, radius: 3)
                      } else {
                        RoundedRectangle(cornerRadius: cornerRadius)
                          .fill(Color.Neumorphic.main)
                          .softOuterShadow()
                      }
                    }
                  )
              }
              .buttonStyle(.plain)
            }
          }
          .padding(.horizontal, 12)

          // View Toggle and Sort
          // HStack {
          // 	Button(action: { showGraph.toggle() }) {
          // 		HStack {
          // 			Image(systemName: showGraph ? "list.bullet" : "chart.bar")
          // 			Text(showGraph ? "Show List" : "Show Chart")
          // 		}
          // 	}
          // 	.softButtonStyle(RoundedRectangle(cornerRadius: cornerRadius))

          // 	Spacer()

          // 	Menu {
          // 		Button("Date (Newest First)") {
          // 			sortOrder = SortDescriptor(\Workout.date, order: .reverse)
          // 		}
          // 		Button("Date (Oldest First)") {
          // 			sortOrder = SortDescriptor(\Workout.date, order: .forward)
          // 		}
          // 		Button("Count (Highest First)") {
          // 			sortOrder = SortDescriptor(\Workout.count, order: .reverse)
          // 		}
          // 		Button("Duration (Longest First)") {
          // 			sortOrder = SortDescriptor(\Workout.duration, order: .reverse)
          // 		}
          // 	} label: {
          // 		HStack {
          // 			Image(systemName: "arrow.up.arrow.down")
          // 			Text("Sort")
          // 		}
          // 		.foregroundColor(.primary)
          // 		.padding()
          // 		.background(Color.Neumorphic.main)
          // 		.clipShape(RoundedRectangle(cornerRadius: cornerRadius))
          // 		.softOuterShadow()
          // 	}
          // }
          // .padding(.horizontal)

          if showGraph {
            WorkoutChart(workouts: filteredAndSortedWorkouts, timeRange: timeRange)
//																		.softOuterShadow()
										
          } else {
            List {
              ForEach(filteredAndSortedWorkouts) { workout in
                WorkoutRow(workout: workout, onDelete: {
                  deleteWorkout(at: IndexSet([filteredAndSortedWorkouts.firstIndex(of: workout)!]))
                })
                .listRowBackground(Color.Neumorphic.main)
                .listRowInsets(EdgeInsets())  // Remove default list row insets
                .listRowSeparator(.hidden)    // Hide default separators
																.padding(.horizontal)
																.padding(.vertical, 8)
              }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.plain)                    // Use plain style to remove additional styling
          }

          Spacer(minLength: 0)  // push content to top
        }
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Text("Workout History")
              .font(.title)
              .fontWeight(.bold)
          }
          // select exercise type in toolbar button with dropdown
          ToolbarItem(placement: .navigationBarTrailing) {
            Picker("Exercise Type", selection: $selectedWorkoutType) {
              Text("Pushups").tag("pushup")
              Text("Squats").tag("squat")
            }
            .pickerStyle(.menu)
          }
          ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
              showGraph.toggle()
            }) {
              Image(systemName: showGraph ? "list.bullet" : "chart.bar")
            }
          }
        }
      }
    }
  }

  var filteredAndSortedWorkouts: [Workout] {
    let filtered = workouts.filter { workout in
      workout.type == selectedWorkoutType
        && workout.date > Calendar.current.date(byAdding: .day, value: -timeRange.days, to: Date())!
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
    filteredAndSortedWorkouts.isEmpty
      ? 0 : Double(totalCount) / Double(filteredAndSortedWorkouts.count)
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
    .softInnerShadow(RoundedRectangle(cornerRadius: 12), spread: 0.05, radius: 1.5)
  }
}

struct WorkoutChart: View {
  let workouts: [Workout]
  let timeRange: StatsView.TimeRange
  @State private var selectedWorkout: Workout?
  
  var body: some View {
    if workouts.isEmpty {
      EmptyChartView()
    } else {
      Chart {
        ForEach(workouts) { workout in
          LineMark(
            x: .value("Date", workout.date),
            y: .value("Count", workout.count)
          )
          .foregroundStyle(workouts.first?.type == "pushup" ? .green : .red)
          .interpolationMethod(.catmullRom)

          AreaMark(
            x: .value("Date", workout.date),
            y: .value("Count", workout.count)
          )
          .foregroundStyle(
            .linearGradient(
              colors: [
                (workouts.first?.type == "pushup" ? Color.green : Color.red).opacity(0.2),
                Color.clear,
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
          .symbolSize(selectedWorkout?.id == workout.id ? 150 : 100)
        }

        if let avg = averageCount {
          RuleMark(y: .value("Average", avg))
            .foregroundStyle(.gray.opacity(0.5))
            .lineStyle(StrokeStyle(dash: [5, 5]))
            .annotation(position: .leading) {
              Text("Avg: \(Int(avg))")
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
      }
      .chartXAxis {
        createXAxis()
      }
      .chartYAxis {
        createYAxis()
      }
      .chartOverlay { proxy in
        createChartOverlay(proxy: proxy)
      }
      .chartBackground { proxy in
        createChartBackground(proxy: proxy)
      }
      .frame(height: 300)
      .padding(35)
      .background(Color.Neumorphic.main)
    }
  }
  
  private var averageCount: Double? {
    guard !workouts.isEmpty else { return nil }
    return Double(workouts.reduce(0) { $0 + $1.count }) / Double(workouts.count)
  }
}

// MARK: - Chart Components
private extension WorkoutChart {
  func createXAxis() -> some AxisContent {
    AxisMarks(preset: .aligned, values: .automatic(desiredCount: timeRange == .week ? 7 : 5)) { value in
								if value.as(Date.self) != nil {
        AxisGridLine()
        AxisValueLabel(
          format: timeRange == .week ? .dateTime.weekday() : .dateTime.month().day()
        )
      }
    }
  }
  
  func createYAxis() -> some AxisContent {
    AxisMarks { value in
      AxisGridLine()
      AxisValueLabel {
        if let count = value.as(Int.self) {
          Text("\(count)")
        }
      }
    }
  }
  
  func createChartOverlay(proxy: ChartProxy) -> some View {
    GeometryReader { geometry in
      Rectangle().fill(.clear).contentShape(Rectangle())
        .gesture(
          SpatialTapGesture()
            .onEnded { value in
              let location = value.location
              if let workout = findWorkout(at: location, proxy: proxy, geometry: geometry) {
                selectedWorkout = selectedWorkout?.id == workout.id ? nil : workout
              }
            }
        )
    }
  }
  
  func createChartBackground(proxy: ChartProxy) -> some View {
    GeometryReader { geometry in
      if let selectedWorkout {
        WorkoutTooltip(workout: selectedWorkout, proxy: proxy)
          .frame(width: geometry.size.width, height: geometry.size.height)
      }
    }
  }
  
  func findWorkout(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> Workout? {
    let relativeXPosition = location.x / geometry.size.width
    guard let date = proxy.value(atX: relativeXPosition) as Date? else { return nil }
    return workouts.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) })
  }
}

// MARK: - Supporting Views
private struct EmptyChartView: View {
  var body: some View {
    VStack(spacing: 12) {
      Image(systemName: "chart.line.uptrend.xyaxis")
        .font(.system(size: 50))
        .foregroundColor(.secondary)
      Text("No workout data for this period")
        .font(.headline)
        .foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity, minHeight: 300)
    .padding()
    .background(Color.Neumorphic.main)
  }
}

private struct WorkoutTooltip: View {
  let workout: Workout
  let proxy: ChartProxy
  
  var body: some View {
    let xPosition = proxy.position(forX: workout.date) ?? 0
    let yPosition = proxy.position(forY: Double(workout.count)) ?? 0
    
    VStack(alignment: .leading, spacing: 4) {
      Text(workout.date.formatted(date: .abbreviated, time: .shortened))
        .font(.caption)
      Text("Count: \(workout.count)")
        .font(.caption.bold())
    }
    .padding(8)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(Color.secondary.opacity(0.1))
    )
    // Offset slightly above the point and to the right
    .offset(x: xPosition + 10, y: yPosition - 40)
    // Ensure tooltip stays within chart bounds
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }
}

struct WorkoutRow: View {
    let workout: Workout
    let onDelete: () -> Void
    
    var body: some View {
        SwipeableRow(onDelete: onDelete) {
            HStack(spacing: 12) {
                Text(workout.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                
                Spacer()
                
                Image(systemName: workout.type == "pushup" ? "figure.pushup" : "figure.squat")
                    .foregroundColor(workout.type == "pushup" ? .green : .red)
                
                Text("\(workout.count)")
                    .font(.headline.bold())
                
                Text(formatDuration(workout.duration))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            return String(format: "%d sec", seconds)
        }
    }
}

struct StatsView_Previews: PreviewProvider {
  static var previews: some View {
    let preview = DataProvider.shared.previewContainer
    DataProvider.loadPreviewData(into: preview)

    return StatsView()
      .modelContainer(preview)
  }
}
