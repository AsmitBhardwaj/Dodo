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
    // NEW
    @State private var selectedCategory: TodoTask.TaskCategory = .ship
    @State private var dueDate: Date
    @State private var selectedDuration: TodoTask.TaskDuration = .short

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
                    VStack(alignment: .leading, spacing: 8) {
                                            Text("How long?")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            HStack(spacing: 8) {
                                                ForEach(TodoTask.TaskDuration.allCases, id: \.self) { d in
                                                    Button(d.label) {
                                                        selectedDuration = d
                                                    }
                                                    .font(.system(size: 13, weight: .medium))
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 6)
                                                    .background(selectedDuration == d ? Color.dodoOrange : Color(.tertiarySystemBackground))
                                                    .foregroundColor(selectedDuration == d ? .black : .primary)
                                                    .clipShape(Capsule())
                                                }
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
            dueDate: dueDate.startOfDay,
            duration: selectedDuration
        )
        taskManager.addTask(newTask)
        dismiss()
    }
}

#Preview {
    AddTaskView()
        .environmentObject(TaskManager())
}
