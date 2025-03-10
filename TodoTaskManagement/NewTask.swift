//
//  NewTask.swift
//  TodoTaskManagement
//
//  Created by Nagaraj, Vignesh  on 06/03/25.
//

import SwiftUI

struct NewTask: View {
    var body: some View {
        Spacer()
        HStack{
            NavigationLink(destination: TaskEditView()) {
                Text(" + New Task!")
            }
            .padding(15)
            .foregroundColor(.white)
            .background(Color.accentColor)
            .cornerRadius(30)
            .padding(30)
            .shadow(color: .black.opacity(0.3), radius: 3, x: 3, y: 3)
        }
        
    }
}

#Preview {
    NewTask()
}
