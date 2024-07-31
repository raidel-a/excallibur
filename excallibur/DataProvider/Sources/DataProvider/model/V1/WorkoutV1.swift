//
//  File.swift
//

import Foundation
import SwiftData

public typealias Workout = SchemaV1.Workout

// MARK: - SchemaV1.Workout

extension SchemaV1 {
	@Model
	public final class Workout {
		// MARK: Lifecycle

		public init(date: Date, duration: TimeInterval, count: Int, type: String) {
			id = UUID()
			self.date = date
			self.duration = duration
			self.count = count
			self.type = type
		}

		// MARK: Public

		@Attribute(.unique) public var id: UUID
		public var date: Date
		public var duration: TimeInterval
		public var count: Int
		public var type: String
	}
}
