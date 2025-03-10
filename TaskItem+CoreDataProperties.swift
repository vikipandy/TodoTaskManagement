//
//  TaskItem+CoreDataProperties.swift
//  TodoTaskManagement
//
//  Created by Nagaraj, Vignesh (Cognizant) on 10/03/25.
//
//

import Foundation
import CoreData


extension TaskItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskItem> {
        return NSFetchRequest<TaskItem>(entityName: "TaskItem")
    }

    @NSManaged public var title: String?
    @NSManaged public var taskdescription: String?
    @NSManaged public var status: String?
    @NSManaged public var scheduleTime: Bool
    @NSManaged public var periority: String?
    @NSManaged public var id: UUID?
    @NSManaged public var dueDate: Date?
    @NSManaged public var created: Date?
    @NSManaged public var category: String?

}

extension TaskItem : Identifiable {

}
