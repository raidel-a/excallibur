//
//  DailyGoalTests.swift
//

@testable import DataProvider
import SwiftData
import XCTest

@MainActor
final class DailyTotalTests: XCTestCase {
	var container: ModelContainer!
	var handler: DataHandler!

	override func setUpWithError() throws {
		let schema = Schema([DailyTotal.self])
		let config = ModelConfiguration(isStoredInMemoryOnly: true)
		container = try ModelContainer(for: schema, configurations: config)
		handler = DataHandler(modelContainer: container, mainActor: true)
	}

	override func tearDownWithError() throws {
		container = nil
		handler = nil
	}

	func testNewDailyTotal() async throws {
		let date = Date()
		let id = try await handler.newDailyTotal(date: date, pushups: 50)

		let fetchDescriptor = FetchDescriptor<DailyTotal>()
		let fetchedTotals = try container.mainContext.fetch(fetchDescriptor)

		XCTAssertEqual(fetchedTotals.count, 1)
		XCTAssertEqual(fetchedTotals[0].persistentModelID, id)
		XCTAssertEqual(fetchedTotals[0].pushups, 50)
		XCTAssertEqual(fetchedTotals[0].date, Calendar.current.startOfDay(for: date))
	}

	func testGetDailyTotal() async throws {
		let date = Date()
		let _ = try await handler.newDailyTotal(date: date, pushups: 50)

		let fetchedTotal = try await handler.getDailyTotal(for: date)

		XCTAssertNotNil(fetchedTotal)
		XCTAssertEqual(fetchedTotal?.pushups, 50)
		XCTAssertEqual(fetchedTotal?.date, Calendar.current.startOfDay(for: date))
	}

	func testUpdateDailyTotal() async throws {
		let date = Date()
		let id = try await handler.newDailyTotal(date: date, pushups: 50)

		try await handler.updateDailyTotal(id: id, pushups: 100)

		let fetchedTotal = try await handler.getDailyTotal(for: date)
		XCTAssertEqual(fetchedTotal?.pushups, 100)
	}

	func testDeleteDailyTotal() async throws {
		let date = Date()
		let id = try await handler.newDailyTotal(date: date, pushups: 50)

		try await handler.deleteDailyTotal(id: id)

		let fetchedTotal = try await handler.getDailyTotal(for: date)
		XCTAssertNil(fetchedTotal)
	}

	func testUniqueDailyTotal() async throws {
		let date = Date()
		let _ = try await handler.newDailyTotal(date: date, pushups: 50)

		do {
			let _ = try await handler.newDailyTotal(date: date, pushups: 100)
			XCTFail("Expected to throw a duplicate entry error")
		} catch DataError.duplicateEntry {
			// This is the expected behavior
		} catch {
			XCTFail("Unexpected error: \(error)")
		}

		let fetchedTotal = try await handler.getDailyTotal(for: date)
		XCTAssertEqual(fetchedTotal?.pushups, 50)
	}
}
