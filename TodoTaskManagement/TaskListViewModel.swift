//
//  Untitled.swift
//  TodoTaskManagement
//
//  Created by Nagaraj, Vignesh  on 08/03/25.
//
import SwiftUI
import CoreData
import UserNotifications

class TaskListViewModel: ObservableObject {
    @Published var tasks: [TaskItem] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: Categories? = nil
    @Published var selectedTask: TaskItem? = nil
    @Published var showingEditView: Bool = false
    @Published var showingCategoryMenu: Bool = false
    @Published var showingStatusMenu: Bool = false
    @Published var taskForStatusUpdate: TaskItem? = nil
    @Published var scheduleTime: Bool = false
    
    private var viewContext: NSManagedObjectContext
    private var timer: Timer?
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        self.scheduleTime = true
        fetchTasks()
        setupTimer()
        checkForOverdueTasks()
        requestNotificationPermission()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func fetchTasks() {
        let request: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskItem.dueDate, ascending: true)]
        
        var predicates: [NSPredicate] = []
        
        // Add search predicate
        if !searchText.isEmpty {
            predicates.append(NSPredicate(format: "title CONTAINS[cd] %@ OR taskdescription CONTAINS[cd] %@",
                                       searchText, searchText))
        }
        
        // Add category predicate
        if let category = selectedCategory {
            predicates.append(NSPredicate(format: "category == %@", category.rawValue))
        }
        
        // Combine predicates
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        do {
            tasks = try viewContext.fetch(request)
        } catch {
            print("Failed to fetch tasks: \(error)")
        }
    }
    
    func updateFilter() {
        fetchTasks()
    }
    
    func addTask() {
        selectedTask = nil
        showingEditView = true
    }
    
    func editTask(_ task: TaskItem) {
        selectedTask = task
        showingEditView = true
    }
    
    func showStatusOptions(for task: TaskItem) {
        taskForStatusUpdate = task
        showingStatusMenu = true
    }
    
    func updateTaskStatus(_ task: TaskItem, status: TaskStatus) {
        task.status = status.rawValue
        saveContext()
        
        // If task is completed, cancel any pending notifications
        if status == .completed, let id = task.id?.uuidString {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        }
    }
    
    func deleteTask(_ task: TaskItem) {
        // Cancel notifications for this task
        if let id = task.id?.uuidString {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        }
        
        viewContext.delete(task)
        saveContext()
        fetchTasks() // Refresh the list
    }
    
    func toggleTaskCompletion(_ task: TaskItem) {
        let newStatus: TaskStatus = task.status == TaskStatus.completed.rawValue ? .pending : .completed
        updateTaskStatus(task, status: newStatus)
    }
    
    private func setupTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.checkForOverdueTasks()
        }
    }
    
    func checkForOverdueTasks() {
        let now = Date()
        var needsUpdate = false
        
        for task in tasks {
            if (task.status == TaskStatus.pending.rawValue || task.status == TaskStatus.inProgress.rawValue),
               let dueDate = task.dueDate,
               dueDate < now {
                // Mark as overdue
                task.status = TaskStatus.overdue.rawValue
                needsUpdate = true
                
                // Send overdue notification
                sendOverdueNotification(for: task)
            }
        }
        
        if needsUpdate {
            saveContext()
            fetchTasks()
        }
    }
    
    func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
                // Schedule notifications for existing tasks
                DispatchQueue.main.async {
                    self.scheduleNotificationsForAllTasks()
                }
            } else if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }
    }
    
    private func scheduleNotificationsForAllTasks() {
        guard scheduleTime else { return }
        for task in tasks {
            if (task.status == TaskStatus.pending.rawValue || task.status == TaskStatus.inProgress.rawValue),
               let dueDate = task.dueDate {
                scheduleReminderNotification(for: task, dueDate: dueDate)
            }
        }
    }
    
    private func scheduleReminderNotification(for task: TaskItem, dueDate: Date) {
        guard scheduleTime else { return }
        guard let id = task.id?.uuidString else { return }
        
        // Cancel any existing notifications for this task
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        
        // Create content
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = "Your task \"\(task.title ?? "Untitled")\" is due soon"
        content.sound = .default
        
        // Schedule notification for 1 hour before due date
        let reminderDate = dueDate.addingTimeInterval(-3600) // 1 hour before
        
        // Only schedule if the reminder time is in the future
        if reminderDate > Date() {
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
    }
    
    private func sendOverdueNotification(for task: TaskItem) {
        guard let id = task.id?.uuidString else { return }
        
        // Create content
        let content = UNMutableNotificationContent()
        content.title = "Task Overdue"
        content.body = "Your task \"\(task.title ?? "Untitled")\" is now overdue"
        content.sound = .default
        
        // Trigger immediately
        let request = UNNotificationRequest(identifier: "\(id)-overdue", content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending overdue notification: \(error)")
            }
        }
    }
    func testNotification() {
        // Create a dummy task
        let testTask = TaskItem(context: viewContext)
        testTask.title = "Test Notification"
        testTask.id = UUID()
        let testDate = Date().addingTimeInterval(120) // Schedule 2 minutes from now

        print("Scheduling test notification for \(testDate)")
        scheduleReminderNotification(for: testTask, dueDate: testDate)
    }
}

