//
//  TaskRow.swift
//  TodoTaskManagement
//
//  Created by Nagaraj, Vignesh  on 07/03/25.
//


import SwiftUI
import CoreData
import UserNotifications
struct TaskRow: View {
    @ObservedObject var task: TaskItem 
    
    var body: some View {
        HStack {
//             Status indicator
            Circle()
                .fill(getStatusColor())
                .frame(width: 12, height: 12)
            
            // Task details
            VStack(alignment: .leading, spacing: 3) {
                Text(task.title ?? "Untitled")
                    .font(.headline)
                    .strikethrough(task.status == TaskStatus.completed.rawValue)
                    .foregroundColor(task.status == TaskStatus.completed.rawValue ? .gray : .primary)
                
                if let dueDate = task.dueDate {
                    Text(formatDate(dueDate))
                        .font(.caption)
                        .foregroundColor(task.status == TaskStatus.overdue.rawValue ? .red : .secondary)
                }
               
            }
            Spacer()
            HStack{
                Text(getPriorityString())
            }
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
    
    private func getStatusImageName(_ status: TaskStatus) -> String {
        switch status {
        case .completed:
            return "checkmark.circle.fill"
        case .overdue:
            return "exclamationmark.circle.fill"
        case .inProgress:
            return "arrow.triangle.2.circlepath.circle.fill"
        default:
            return "circle"
        }
    }
        private func getStatusColor() -> Color {
            switch task.status {
            case TaskStatus.completed.rawValue:
                return .green
            case TaskStatus.overdue.rawValue:
                return .red
            case TaskStatus.inProgress.rawValue:
                return .orange
            default:
                return .blue
            }
        }
    //
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    func getPriorityString() -> String {
        guard let priorityValue = Int(task.periority ?? "Medium"),
              let priority = TaskPriority(rawValue: priorityValue) else {
            return "Unknown"
        }
        switch priority {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        case .urgent:
            return "Urgent"
        }
    }
}

