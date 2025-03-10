//
//  ContentView.swift
//  TodoTaskManagement
//
//  Created by Nagaraj, Vignesh  on 05/03/25.
//

import SwiftUI
import CoreData
import UserNotifications
// Assuming this is your TaskStatus enum
struct TaskList: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TaskItem.created, ascending: true)],
        animation: .default)

    private var tasks: FetchedResults<TaskItem>
    @StateObject private var viewModel: TaskListViewModel

    init(viewContext: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: TaskListViewModel(viewContext: viewContext))
    }
   
    @State private var searchText = ""
    @State private var selectedCategory: Categories?
    @State private var showingEditView = false
    @State private var selectedTask: TaskItem?
    @State private var showingCategoryMenu = false
    @State private var taskForStatusUpdate: TaskItem?
    @State private var showingStatusPicker = false
    // Timer to periodically check for overdue tasks
    let timer = Timer.publish(every: 3600, on: .main, in: .common).autoconnect() // Check every hour
    
    var body: some View {
        NavigationView {
            
                VStack {
                    
                    TextField("Search tasks", text: $viewModel.searchText)
                        .padding(7)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .onChange(of: viewModel.searchText) { _ in
                            viewModel.updateFilter()
                        }
                    if let category = viewModel.selectedCategory {
                        HStack {
                            Text("Filtered by: \(category.rawValue)")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 10)
                                .background(getCategoryColor(category.rawValue))
                                .cornerRadius(8)
                            
                            Button(action: {
                                viewModel.selectedCategory = nil
                                viewModel.updateFilter()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 4)
                    }
                    
                    List{
                        ForEach(viewModel.tasks, id: \.self) { task in
                            TaskRow(task: task)
                                .background(Color.clear)
                                .onTapGesture {
                                    viewModel.showStatusOptions(for: task)
                                    
                                }
                                .contextMenu { // Add a context menu to select status
                                                Button(action: {
                                                    viewModel.updateTaskStatus(task, status: .completed)
                                                }) {
                                                    Label("Mark as Complete", systemImage: "checkmark.circle")
                                                }
                                                Button(action: {
                                                    viewModel.updateTaskStatus(task, status: .inProgress)
                                                }) {
                                                    Label("Mark as In Progress", systemImage: "clock")
                                                }
                                                Button(action: {
                                                    viewModel.updateTaskStatus(task, status: .overdue)
                                                }) {
                                                    Label("Mark as Overdue", systemImage: "exclamationmark.triangle")
                                                }
                                            }
                        }
                    }
                   
                    NewTask()
                    
        } .navigationTitle("Task Manager")
                .navigationBarItems(
                leading: Button(action: {
                    viewModel.showingCategoryMenu  = true
                }) {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text("Categories")
                    }
                }
            )
                .confirmationDialog("Select Category", isPresented: $viewModel.showingCategoryMenu) {
                            categorySelectionDialog() // Simplified
                        }
                        .sheet(isPresented: $viewModel.showingEditView) {
                            editTaskSheet() // Simplified
                        }
                        .confirmationDialog("Update Status", isPresented: $viewModel.showingStatusMenu) {
                            statusUpdateDialog()
                        }
                         .onAppear {
                             viewModel.fetchTasks()
                         }
    }
       
    }
    
    private func deleteTask(at offsetindex : IndexSet) {
        withAnimation() {
            offsetindex.map{ tasks[$0]}.forEach { task in
                if let id = task.id?.uuidString {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
                }
                viewContext.delete(task)
            }
            do {
                try viewContext.save()
            }catch {
                print("Error deleting task: \(error)")
            }
        }
    }
     
    // More memory-efficient filter update
   
    private func addItem() {
        withAnimation {
            let newItem = TaskItem(context: viewContext)
            newItem.created = Date()

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func getLabelAttributes(for status: String) -> (text: String, systemImage: String) {
        if status == TaskStatus.completed.rawValue {
            return ("MARK PENDING", "circle")
        } else {
            return ("Completed", "checkmark.circle")
        }
    }
    
    private func updateTaskStatus(_ task: TaskItem, status: TaskStatus) {
        task.status = status.rawValue
        
        do {
            try viewContext.save()
            
            // If task is completed, cancel any pending notifications
            if status == .completed, let id = task.id?.uuidString {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
            }
        } catch {
            print("Error updating task status: \(error)")
        }
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
    // Save context safely
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    // Simple toggle for task completion
    private func toggleTaskCompletion(_ task: TaskItem) {
        withAnimation {
            task.status = task.status == TaskStatus.completed.rawValue ?
                           TaskStatus.pending.rawValue :
                           TaskStatus.completed.rawValue
            saveContext()
        }
    }
    
    private func getCategoryColor(_ category: String) -> Color {
        switch category {
        case "Work":
            return .blue
        case "Shopping":
            return .green
        case "Personal":
            return .purple
        default:
            return .gray
        }
    }
}

extension TaskList {
    private func categorySelectionDialog() -> some View {

            Group {
                Button("All Categories") {
                    viewModel.selectedCategory = nil
                    viewModel.updateFilter()
                }
                Button("Work") {
                    if let workCategory = Categories.category.first(where: { $0.rawValue == "Work" }) {
                        viewModel.selectedCategory = workCategory
                        viewModel.updateFilter()
                    }
                }
                Button("Shopping") {
                    if let shoppingCategory = Categories.category.first(where: { $0.rawValue == "Shopping" }) {
                        viewModel.selectedCategory = shoppingCategory
                        viewModel.updateFilter()
                    }
                }
                Button("Personal") {
                    if let personalCategory = Categories.category.first(where: { $0.rawValue == "Personal" }) {
                        viewModel.selectedCategory = personalCategory
                        viewModel.updateFilter()
                    }
                }
            }
        }
    }

extension TaskList {
    private func editTaskSheet() -> some View {
        TaskEditView(selectedTaskItem: viewModel.selectedTask)
            .environment(\.managedObjectContext, viewContext)
    }
}

extension TaskList {
    private func statusUpdateDialog() -> some View {
        ForEach(TaskStatus.allCases, id: \.id) { status in
            Button(status.displayName) {
                if let task = viewModel.taskForStatusUpdate {
                    viewModel.updateTaskStatus(task, status: status)
                }
            }
        }
    }
}

