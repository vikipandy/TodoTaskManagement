//
//  Untitled.swift
//  TodoTaskManagement
//
//  Created by Nagaraj, Vignesh  on 06/03/25.
//


import Foundation
import CoreLocation
import SwiftUI

enum TaskPriority: Int {
    case low = 1
    case medium = 2
    case high = 3
    case urgent = 4
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .urgent: return .red
        }
    }
}
 
enum Categories: String {
    static var category: [Categories] {
        return [.Work, .Shopping, .Personal]
    }
    case Work = "Work"
    case Shopping = "Shopping"
    case Personal = "Personal"
}
 
enum TaskStatus: String, CaseIterable, Identifiable {
    case completed = "Completed"
    case inProgress = "inProgress"
    case pending = "Pending"
    case overdue = "Overdue"
    
    var id: String { rawValue } // Conformance to Identifiable
    
    var displayName: String {
        switch self {
        case .completed: return "Completed"
        case .pending: return "Pending"
        case .overdue: return "Overdue"
        case .inProgress:
            return "inProgress"
        }
    }
}
struct Task: Identifiable {
    let id: UUID
    var title: String
    var taskDescription: String
    var createdAt: Date
    var dueDate: Date?
    var priority: TaskPriority
    var status: TaskStatus
    var categories: Categories
    var location: TaskLocation?
    var scheduleTime : Bool
    init(
        id: UUID = UUID(),
        title: String,
        taskDescription: String = "",
        createdAt: Date = Date(),
        dueDate: Date? = nil,
        priority: TaskPriority = .medium,
        status: TaskStatus = .inProgress,
        categories: Categories = .Work,
        location: TaskLocation? = nil,
        scheduleTime : Bool
    ) {
        self.id = id
        self.title = title
        self.taskDescription = taskDescription
        self.createdAt = createdAt
        self.dueDate = dueDate
        self.priority = priority
        self.status = status
        self.categories = categories
        self.location = location
        self.scheduleTime = scheduleTime
    }
}
struct TaskLocation {
    let latitude: Double
    let longitude: Double
    let radius: Double
    let name: String
    init(latitude: Double, longitude: Double, radius: Double = 100, name: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        self.name = name
    }
}

