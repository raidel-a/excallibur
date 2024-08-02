//
//  DataHandler.swift
//

import Foundation
import SwiftData

// MARK: - DataHandler

@ModelActor
public actor DataHandler {
	// MARK: Lifecycle

	@MainActor
	public init(modelContainer: ModelContainer, mainActor _: Bool) {
		let modelContext = modelContainer.mainContext
		modelExecutor = DefaultSerialModelExecutor(modelContext: modelContext)
		self.modelContainer = modelContainer
	}

	// MARK: Public

	@discardableResult
	public func newWorkout(
		date: Date,
		duration: TimeInterval,
		count: Int,
		type: String
	) throws -> PersistentIdentifier {
		let workout = Workout(date: date, duration: duration, count: count, type: type)
		modelContext.insert(workout)
		try modelContext.save()
		return workout.persistentModelID
	}

	public func updateWorkout(
		id: PersistentIdentifier,
		date: Date,
		duration: TimeInterval,
		count: Int,
		type: String
	) throws {
		guard let workout = self[id, as: Workout.self] else { return }
		workout.date = date
		workout.duration = duration
		workout.count = count
		workout.type = type
		try modelContext.save()
	}

	public func deleteWorkout(id: PersistentIdentifier) throws {
		guard let workout = self[id, as: Workout.self] else { return }
		modelContext.delete(workout)
		try modelContext.save()
	}

	// MARK: - DailyTotal CRUD Operations
	
	@discardableResult
	public func updateOrCreateDailyTotal(date: Date, pushups: Int? = nil, pushupsGoal: Int? = nil) throws -> PersistentIdentifier {
		if let existingTotal = try getDailyTotal(for: date) {
			if let pushups = pushups {
				existingTotal.pushups = pushups
			}
			if let pushupsGoal = pushupsGoal {
				existingTotal.pushupsGoal = pushupsGoal
			}
			try modelContext.save()
			return existingTotal.persistentModelID
		} else {
			let newTotal = DailyTotal(date: date, pushups: pushups ?? 0, pushupsGoal: pushupsGoal ?? 0)
			modelContext.insert(newTotal)
			try modelContext.save()
			return newTotal.persistentModelID
		}
	}
	
	public func getDailyTotal(for date: Date) throws -> DailyTotal? {
		let startOfDay = Calendar.current.startOfDay(for: date)
		let predicate = #Predicate<DailyTotal> { $0.date == startOfDay }
		let descriptor = FetchDescriptor<DailyTotal>(predicate: predicate)
		let results = try modelContext.fetch(descriptor)
		return results.first
	}

	public func deleteDailyTotal(id: PersistentIdentifier) throws {
		guard let dailyTotal = self[id, as: DailyTotal.self] else { return }
		modelContext.delete(dailyTotal)
		try modelContext.save()
	}

	// MARK: Private

	// Helper method to ensure uniqueness
	private func ensureUniqueDailyTotal(date: Date) throws {
		let existingTotal = try getDailyTotal(for: date)
		if existingTotal != nil {
			throw DataError.duplicateEntry
		}
	}
}

// MARK: - DataError

enum DataError: Error {
	case duplicateEntry
}
