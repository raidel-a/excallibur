// The Swift Programming Language
// https://docs.swift.org/swift-book

// DataProvider.swift

import Foundation
import SwiftData
import SwiftUI

// MARK: - DataProvider

public final class DataProvider: Sendable {
	public static let shared = DataProvider()

	public let sharedModelContainer: ModelContainer = {
		let schema = Schema(CurrentScheme.models)
		let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

		do {
			return try ModelContainer(for: schema, configurations: [modelConfiguration])
		} catch {
			fatalError("Could not create ModelContainer: \(error)")
		}
	}()

	public let previewContainer: ModelContainer = {
		let schema = Schema(CurrentScheme.models)
		let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
		do {
			return try ModelContainer(for: schema, configurations: [modelConfiguration])
		} catch {
			fatalError("Could not create ModelContainer: \(error)")
		}
	}()

	public func dataHandlerCreator(preview: Bool = false) -> @Sendable () async -> DataHandler {
		let container = preview ? previewContainer : sharedModelContainer
		return { DataHandler(modelContainer: container) }
	}

	public func dataHandlerWithMainContextCreator(preview: Bool = false) -> @Sendable @MainActor () async -> DataHandler {
		let container = preview ? previewContainer : sharedModelContainer
		return { DataHandler(modelContainer: container, mainActor: true) }
	}
}

// MARK: - DataHandlerKey

public struct DataHandlerKey: EnvironmentKey {
	public static let defaultValue: @Sendable () async -> DataHandler? = { nil }
}

public extension EnvironmentValues {
	var createDataHandler: @Sendable () async -> DataHandler? {
		get { self[DataHandlerKey.self] }
		set { self[DataHandlerKey.self] = newValue }
	}
}

// MARK: - MainActorDataHandlerKey

public struct MainActorDataHandlerKey: EnvironmentKey {
	public static let defaultValue: @Sendable @MainActor () async -> DataHandler? = { nil }
}

public extension EnvironmentValues {
	var createDataHandlerWithMainContext: @Sendable @MainActor () async -> DataHandler? {
		get { self[MainActorDataHandlerKey.self] }
		set { self[MainActorDataHandlerKey.self] = newValue }
	}
}
