import Foundation
import SwiftData

public extension DataProvider {
    @MainActor
    static func loadPreviewData(into container: ModelContainer) {
        // First try the main bundle
        let bundle = Bundle.main
        
        guard let url = bundle.url(forResource: "seed", withExtension: "json") else {
            print("Could not find seed.json in bundle:", bundle)
            print("Bundle path:", bundle.bundlePath)
            return
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let data = try? Data(contentsOf: url),
              let json = try? decoder.decode(SeedData.self, from: data) else {
            print("Failed to decode seed.json")
            if let data = try? Data(contentsOf: url),
               let jsonString = String(data: data, encoding: .utf8) {
                print("JSON content:", jsonString)
            }
            return
        }
        
        let context = container.mainContext
        
        // Load workouts
        for workoutData in json.workouts {
            let workout = Workout(
                date: workoutData.date,
                duration: workoutData.duration,
                count: workoutData.count,
                type: workoutData.type
            )
            context.insert(workout)
        }
        
        // Load daily totals
        for totalData in json.dailyTotals {
            let dailyTotal = DailyTotal(
                date: totalData.date,
                pushups: totalData.pushups,
                pushupsGoal: totalData.pushupsGoal
            )
            context.insert(dailyTotal)
        }
        
        try? context.save()
    }
}

// MARK: - Seed Data Structures
private struct SeedData: Codable {
    let workouts: [WorkoutData]
    let dailyTotals: [DailyTotalData]
}

private struct WorkoutData: Codable {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    let count: Int
    let type: String
}

private struct DailyTotalData: Codable {
    let date: Date
    let pushups: Int
    let pushupsGoal: Int
} 