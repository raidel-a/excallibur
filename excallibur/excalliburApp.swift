//
// excalliburApp.swift
//

import DataProvider
import SwiftData
import SwiftUI

@main
struct excalliburApp: App {
		@AppStorage("isDarkMode") private var isDarkMode = false
		let dataProvider = DataProvider.shared

		var body: some Scene {
				WindowGroup {
						TabBarView()
								.preferredColorScheme(isDarkMode ? .dark : .light)
								.environment(\.createDataHandler, dataProvider.dataHandlerCreator())
				}
				.modelContainer(dataProvider.sharedModelContainer)
		}
}
