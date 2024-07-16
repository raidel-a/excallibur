//
//  WorkoutModel.swift
//  excallibur
//
//  Created by Raidel Almeida on 7/11/24.
//

import Foundation
import SwiftData

//@Model
//final class WorkoutData {
//    @Attribute(.unique) var id: UUID
//    var date: Date
//    var duration: TimeInterval
//    var count: Int
//    var type: String
//    
//    init(id: UUID = UUID(), date: Date, duration: TimeInterval, count: Int, type: String) {
//        self.id = id
//        self.date = date
//        self.duration = duration
//        self.count = count
//        self.type = type
//    }
//}

@Model
final class WorkoutData: Codable {
    @Attribute(.unique) var id: UUID
    var date: Date
    var duration: TimeInterval
    var count: Int
    var type: String
    
    enum CodingKeys: String, CodingKey {
        case id, date, duration, count, type
    }
    
    init(id: UUID = UUID(), date: Date, duration: TimeInterval, count: Int, type: String) {
        self.id = id
        self.date = date
        self.duration = duration
        self.count = count
        self.type = type
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        count = try container.decode(Int.self, forKey: .count)
        type = try container.decode(String.self, forKey: .type)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(duration, forKey: .duration)
        try container.encode(count, forKey: .count)
        try container.encode(type, forKey: .type)
    }
}
