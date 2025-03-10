//
//  TaskEditView.swift
//  TodoTaskManagement
//
//  Created by Nagaraj, Vignesh  on 06/03/25.
//

import SwiftUI

struct TaskEditView: View {
    
    @State var selectedTaskItem: TaskItem?
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @Environment(\.presentationMode) var presentationMode

    @State private var title = ""

    @State private var taskDescription = ""

    @State private var dueDate: Date?

    @State private var priority: TaskPriority = .medium

    @State private var categories: Categories = .Work

    @State private var newCategory = ""

    @State private var isAddLocationShown = false

    @State private var selectedLocation: TaskLocation?
    
    @State private var scheduleTime: Bool?
  
    
    var body: some View {
        NavigationView {
        
        Form {
            
            Section(header: Text("Task Details")) {
                
                TextField("Title", text: $title)
                
                TextField("Description", text: $taskDescription)
                
                Picker("Priority", selection: $priority) {
                    
                    Text("Low").tag(TaskPriority.low)
                    
                    Text("Medium").tag(TaskPriority.medium)
                    
                    Text("High").tag(TaskPriority.high)
                    
                }
                
            }
            
            Section(header: Text("Due Date")) {
                
                Toggle("Set Due Date", isOn: Binding(
                    
                    get: { dueDate != nil },
                    
                    set: {
                        
                        dueDate = $0 ? Date().addingTimeInterval(86400) : nil
                        
                    }
                    
                ))
                
                if dueDate != nil {
                    
                    Toggle("Schedule Time", isOn: Binding(
                                get: { scheduleTime ?? false }, // Default to `false` if `scheduleTime` is `nil`
                                set: { scheduleTime = $0 }     // Update `scheduleTime` value
                            ))
                    
                    DatePicker("Due Date", selection: Binding(
                        
                        get: { dueDate ?? Date() },
                        
                        set: { dueDate = $0 }
                        
                    ), displayedComponents: scheduleTime == true ? [.hourAndMinute, .date] : [.date])
                    
                }
                
                // Categories Section
                Picker("Categories", selection: $categories) {
                    
                    Text("Work").tag(Categories.Work)
                    
                    Text("Shopping").tag(Categories.Shopping)
                    
                    Text("Personal").tag(Categories.Personal)
                    
                    
                    
                }
            }
            
            // Location Section
            
            Section(header: Text("Location")) {
                
                Button(action: { isAddLocationShown = true }) {
                    
                    HStack {
                        
                        Image(systemName: "location.fill")
                        
                        Text(selectedLocation?.name ?? "Add Location")
                        
                    }
                    
                }
                
                if let location = selectedLocation {
                    
                    Text("Latitude: \(location.latitude)")
                    
                    Text("Longitude: \(location.longitude)")
                    
                }
                
            }
            
        }
    }

            .navigationTitle("Add New Task")

            .navigationBarItems(

                leading: Button("Cancel") {

                    presentationMode.wrappedValue.dismiss()

                },

                trailing: Button("Save") {

                    saveTask()

                }

                .disabled(title.isEmpty)

            )

            .sheet(isPresented: $isAddLocationShown) {

                LocationPickerView(selectedLocation: $selectedLocation)

            }
        
        

        }
    func saveTask() {
        withAnimation {
            let newTask = Task(
                title: title,
                taskDescription: taskDescription,
                dueDate: dueDate,
                priority: priority,
                status: .inProgress,
                categories: categories,
                location: selectedLocation,
                scheduleTime: scheduleTime ?? false
            )
            
            // Then create or update the Core Data entity
            
            var taskEntity : TaskItem
            if let selectedTaskItem = selectedTaskItem {
                taskEntity = selectedTaskItem
            }else {
                taskEntity = TaskItem(context: viewContext)
            }
            
            // Copy values from your model to Core Data
            taskEntity.id = newTask.id
            taskEntity.title = newTask.title
            taskEntity.taskdescription = newTask.taskDescription
            taskEntity.dueDate = newTask.dueDate
            taskEntity.periority = String(newTask.priority.rawValue)
            taskEntity.status = String(newTask.status.rawValue)
            taskEntity.category = newTask.categories.rawValue
            taskEntity.scheduleTime = newTask.scheduleTime
            // Schedule notifications if due date is set
            
            if let dueDate = dueDate {
                
                //                NotificationManager.shared.sendTaskDueNotification(for: newTask)
                
            }
            
            //            presentationMode.wrappedValue.dismiss()
            do {
                try viewContext.save()
                self.presentationMode.wrappedValue.dismiss()
            } catch {
                print("Error saving: \(error)")
            }
        }
    }
    
    
}

