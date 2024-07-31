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
	public func newDailyTotal(
		date: Date,
		pushups: Int
	) throws -> PersistentIdentifier {
		try ensureUniqueDailyTotal(date: date)
		let dailyTotal = DailyTotal(date: date, pushups: pushups)
		modelContext.insert(dailyTotal)
		try modelContext.save()
		return dailyTotal.persistentModelID
	}

	public func getDailyTotal(for date: Date) throws -> DailyTotal? {
		let startOfDay = Calendar.current.startOfDay(for: date)
		let predicate = #Predicate<DailyTotal> { $0.date == startOfDay }
		let descriptor = FetchDescriptor<DailyTotal>(predicate: predicate)
		let results = try modelContext.fetch(descriptor)
		return results.first
	}

	public func updateDailyTotal(
		id: PersistentIdentifier,
		pushups: Int
	) throws {
		guard let dailyTotal = self[id, as: DailyTotal.self] else { return }
		dailyTotal.pushups = pushups
		try modelContext.save()
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
