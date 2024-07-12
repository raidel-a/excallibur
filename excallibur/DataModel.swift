//
//  WorkoutModel.swift
//  excallibur
//
//  Created by Raidel Almeida on 7/11/24.
//

import Foundation
import SwiftData

@Model
class WorkoutData {
    var date: Date
    var duration: TimeInterval
    var count: Int
    var type: WorkoutType
    
    init(date: Date, duration: TimeInterval, count: Int, type: WorkoutType) {
        self.date = date
        self.duration = duration
        self.count = count
        self.type = type
    }
}

enum WorkoutType: String, Codable {
    case pushup
    case squat
}
