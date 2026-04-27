//
//  AddTaskView.swift
//  Dodo - Life Gamification
//

import SwiftUI
import Combine

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var taskManager: TaskManager

    var defaultDate: Date = Date().startOfDay

    @State private var taskTitle = ""
    @State private var selectedCategory: TodoTask.TaskCategory = .school
    @State private var dueDate: Date

    init(defaultDate: Date = Date().startOfDay) {
        self.defaultDate = defaultDate
        _dueDate = State(initialValue: defaultDate)
    }

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
                    
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                        .tint(.dodoOrange)
                    
                }
                
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") { addTask() }
                        .disabled(taskTitle.isEmpty)
                        .tint(.dodoOrange)
                }
            }
        }
    }

    private func addTask() {
        let newTask = TodoTask(
            title: taskTitle,
            category: selectedCategory,
            rewardValue: 0,
            dueDate: dueDate.startOfDay
        )
        taskManager.addTask(newTask)
        dismiss()
    }
}

#Preview {
    AddTaskView()
        .environmentObject(TaskManager())
}
