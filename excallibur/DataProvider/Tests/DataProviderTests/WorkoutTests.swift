//
// WorkoutTests.swift
//

@testable import DataProvider
import Foundation
import SwiftData
import XCTest

final class WorkoutTests: XCTestCase {
	@MainActor
	func testCreateWorkout() throws {
		// Arrange
		let container = try ContainerForTest.temp(#function)
		let context = container.mainContext

		// Act
		let date = Date()
		let workout = Workout(date: date, duration: 300, count: 100, type: "Pushups")
		context.insert(workout)

		// Assert
		let fetchDescriptor = FetchDescriptor<Workout>()
		let workouts = try context.fetch(fetchDescriptor)

		XCTAssertEqual(workouts.count, 1, "There should be exactly one Workout in the store.")

		if let fetchedWorkout = workouts.first {
			XCTAssertEqual(fetchedWorkout.date, date, "The Workout's date should match the provided date.")
			XCTAssertEqual(fetchedWorkout.duration, 300, "The Workout's duration should be 300 seconds.")
			XCTAssertEqual(fetchedWorkout.count, 100, "The Workout's count should be 100.")
			XCTAssertEqual(fetchedWorkout.type, "Pushups", "The Workout's type should be 'Pushups'.")
		} else {
			XCTFail("Expected to find a Workout but none was found.")
		}
	}

	@MainActor
	func testMultipleWorkoutsPerDay() async throws {
		// Arrange
		let container = try ContainerForTest.temp(#function)
		let handler = DataHandler(modelContainer: container, mainActor: true)

		// Act
		let date = Date()
		let id1 = try await handler.newWorkout(date: date, duration: 300, count: 100, type: "Pushups")
		let id2 = try await handler.newWorkout(date: date, duration: 400, count: 200, type: "Situps")

		// Assert
		let fetchDescriptor = FetchDescriptor<Workout>()
		let fetchedWorkouts = try container.mainContext.fetch(fetchDescriptor)

		XCTAssertEqual(fetchedWorkouts.count, 2, "There should be two Workout entries")

		let sortedWorkouts = fetchedWorkouts.sorted { $0.duration < $1.duration }

		XCTAssertEqual(sortedWorkouts[0].persistentModelID, id1, "The first workout should match the first inserted workout")
		XCTAssertEqual(sortedWorkouts[0].date, date, "The first workout should have the correct date")
		XCTAssertEqual(sortedWorkouts[0].duration, 300, "The first workout should have duration 300")
		XCTAssertEqual(sortedWorkouts[0].count, 100, "The first workout should have count 100")
		XCTAssertEqual(sortedWorkouts[0].type, "Pushups", "The first workout should be Pushups")

		XCTAssertEqual(sortedWorkouts[1].persistentModelID, id2, "The second workout should match the second inserted workout")
		XCTAssertEqual(sortedWorkouts[1].date, date, "The second workout should have the correct date")
		XCTAssertEqual(sortedWorkouts[1].duration, 400, "The second workout should have duration 400")
		XCTAssertEqual(sortedWorkouts[1].count, 200, "The second workout should have count 200")
		XCTAssertEqual(sortedWorkouts[1].type, "Situps", "The second workout should be Situps")
	}

	@MainActor
	func testDataHandlerCreateWorkout() async throws {
		// Arrange
		let container = try ContainerForTest.temp(#function)
		let handler = DataHandler(modelContainer: container, mainActor: true)

		// Act
		let date = Date()
		let id = try await handler.newWorkout(date: date, duration: 300, count: 100, type: "Pushups")

		// Assert
		let fetchDescriptor = FetchDescriptor<Workout>()
		let workouts = try container.mainContext.fetch(fetchDescriptor)

		XCTAssertEqual(workouts.count, 1, "There should be exactly one Workout in the store.")

		if let fetchedWorkout = workouts.first {
			XCTAssertEqual(fetchedWorkout.persistentModelID, id, "The returned ID should match the fetched workout's ID.")
			XCTAssertEqual(fetchedWorkout.date, date, "The Workout's date should match the provided date.")
			XCTAssertEqual(fetchedWorkout.duration, 300, "The Workout's duration should be 300 seconds.")
			XCTAssertEqual(fetchedWorkout.count, 100, "The Workout's count should be 100.")
			XCTAssertEqual(fetchedWorkout.type, "Pushups", "The Workout's type should be 'Pushups'.")
		} else {
			XCTFail("Expected to find a Workout but none was found.")
		}
	}

	@MainActor
	func testUpdateWorkout() async throws {
		// Arrange
		let container = try ContainerForTest.temp(#function)
		let handler = DataHandler(modelContainer: container, mainActor: true)

		// Act
		let initialDate = Date()
		let id = try await handler.newWorkout(date: initialDate, duration: 300, count: 100, type: "Pushups")

		let updatedDate = initialDate.addingTimeInterval(3600) // 1 hour later
		try await handler.updateWorkout(id: id, date: updatedDate, duration: 400, count: 150, type: "Squats")

		// Assert
		let fetchDescriptor = FetchDescriptor<Workout>()
		let workouts = try container.mainContext.fetch(fetchDescriptor)

		XCTAssertEqual(workouts.count, 1, "There should still be exactly one Workout in the store.")

		if let fetchedWorkout = workouts.first {
			XCTAssertEqual(fetchedWorkout.persistentModelID, id, "The ID should remain the same after update.")
			XCTAssertEqual(fetchedWorkout.date, updatedDate, "The Workout's date should be updated.")
			XCTAssertEqual(fetchedWorkout.duration, 400, "The Workout's duration should be updated to 400 seconds.")
			XCTAssertEqual(fetchedWorkout.count, 150, "The Workout's count should be updated to 150.")
			XCTAssertEqual(fetchedWorkout.type, "Squats", "The Workout's type should be updated to 'Squats'.")
		} else {
			XCTFail("Expected to find a Workout but none was found.")
		}
	}

	@MainActor
	func testDeleteWorkout() async throws {
		// Arrange
		let container = try ContainerForTest.temp(#function)
		let handler = DataHandler(modelContainer: container, mainActor: true)

		// Act
		let date = Date()
		let id = try await handler.newWorkout(date: date, duration: 300, count: 100, type: "Pushups")

		// Assert initial state
		var fetchDescriptor = FetchDescriptor<Workout>()
		var workouts = try container.mainContext.fetch(fetchDescriptor)
		XCTAssertEqual(workouts.count, 1, "There should be one Workout in the store initially.")

		// Delete the workout
		try await handler.deleteWorkout(id: id)

		// Assert final state
		fetchDescriptor = FetchDescriptor<Workout>()
		workouts = try container.mainContext.fetch(fetchDescriptor)
		XCTAssertEqual(workouts.count, 0, "There should be no Workouts in the store after deletion.")
	}
}
