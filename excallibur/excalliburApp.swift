//
// excalliburApp.swift
//

import DataProvider
import SwiftData
import SwiftUI

@main
struct excalliburApp: App {
		let dataProvider = DataProvider.shared

		var body: some Scene {
				WindowGroup {
						TabBarView()
								.environment(\.createDataHandler, dataProvider.dataHandlerCreator())
				}
				.modelContainer(dataProvider.sharedModelContainer)
		}
}
