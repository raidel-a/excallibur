//
//  DailyGoalV1.swift
//

import Foundation
import SwiftData

public typealias DailyTotal = SchemaV1.DailyTotal

// MARK: - SchemaV1.DailyTotal

extension SchemaV1 {
	@Model
	public final class DailyTotal {
		// MARK: Lifecycle

		public init(date: Date, pushups: Int, pushupsGoal: Int) {
			self.date = Calendar.current.startOfDay(for: date)
			self.pushups = pushups
			self.pushupsGoal = pushupsGoal
		}

		// MARK: Public

		@Attribute(.unique) public var date: Date
		public var pushups: Int
		public var pushupsGoal: Int
	}
}
