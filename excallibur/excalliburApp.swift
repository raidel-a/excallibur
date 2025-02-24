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

	    init() {
        // Check if this is the first launch
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            DataProvider.loadPreviewData(into: dataProvider.sharedModelContainer)
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }

		var body: some Scene {
				WindowGroup {
						TabBarView()
								.preferredColorScheme(isDarkMode ? .dark : .light)
								.environment(\.createDataHandler, dataProvider.dataHandlerCreator())
				}
				.modelContainer(dataProvider.sharedModelContainer)
		}
}
