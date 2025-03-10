//
//  TodoTaskManagementApp.swift
//  TodoTaskManagement
//
//  Created by Nagaraj, Vignesh (Cognizant) on 10/03/25.
//

import SwiftUI

@main
struct TodoTaskManagementApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TaskList(viewContext: persistenceController.container.viewContext)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
