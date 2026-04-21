//
//  AddTaskView.swift
//  Dodo - Life Gamification
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var taskManager: TaskManager
    
    @State private var taskTitle = ""
    @State private var selectedCategory: TodoTask.TaskCategory = .personal
    @State private var rewardValue = 10
    
    var body: some View {
        NavigationView {
            Form {
                Section("Task Details") {
                    TextField("What do you need to do?", text: $taskTitle)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(TodoTask.TaskCategory.allCases, id: \.self) { category in
                            HStack {
                                Text(category.emoji)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    
                    Stepper("Reward: \(rewardValue) points", value: $rewardValue, in: 5...50, step: 5)
                }
                
                Section {
                    Text("Completing this task will give Dodo \(rewardValue) points!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addTask()
                    }
                    .disabled(taskTitle.isEmpty)
                }
            }
        }
    }
    
    private func addTask() {
        let newTask = TodoTask(
            title: taskTitle,
            category: selectedCategory,
            rewardValue: rewardValue
        )
        taskManager.addTask(newTask)
        dismiss()
    }
}

#Preview {
    AddTaskView()
        .environmentObject(TaskManager())
}
