//
//  Task.swift
//  Dodo - Life Gamification
//

import Foundation
import Combine

// MARK: - Date Helpers

extension Date {
    /// Midnight of this date in the local calendar
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// True if this date falls on the same calendar day as `other`
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }
}

// MARK: - Model

struct TodoTask: Identifiable, Codable {
    var id = UUID()
    var title: String
    var category: TaskCategory
    var isCompleted: Bool = false
    var completedDate: Date?
    var rewardValue: Int
    /// Defaults to midnight of the day the task was created
    var dueDate: Date = Date().startOfDay

    enum TaskCategory: String, Codable, CaseIterable {
        case school   = "School"
        case health   = "Health"
        case personal = "Personal"
        case social   = "Social"

        var emoji: String {
            switch self {
            case .school:   return "📚"
            case .health:   return "💪"
            case .personal: return "✨"
            case .social:   return "👥"
            }
        }

        var color: String {
            switch self {
            case .school:   return "orange"
            case .health:   return "green"
            case .personal: return "purple"
            case .social:   return "blue"
            }
        }
    }
}

// MARK: - Manager

class TaskManager: ObservableObject {
    @Published var tasks: [TodoTask] = []

    init() {
        loadTasks()
    }

    // MARK: - CRUD

    func addTask(_ task: TodoTask) {
        tasks.append(task)
        saveTasks()
    }

    func completeTask(_ task: TodoTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isCompleted = true
        tasks[index].completedDate = Date()
        saveTasks()
    }

    func deleteTask(_ task: TodoTask) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }

    // MARK: - Date Filtering

    func tasks(for date: Date) -> [TodoTask] {
        tasks.filter { $0.dueDate.isSameDay(as: date) }
    }

    func pendingTasks(for date: Date) -> [TodoTask] {
        tasks(for: date).filter { !$0.isCompleted }
    }

    func completedTasks(for date: Date) -> [TodoTask] {
        tasks(for: date).filter { $0.isCompleted }
    }

    /// 0.0–1.0 completion ratio for a day. Returns 0 if no tasks.
    func progress(for date: Date) -> Double {
        let all = tasks(for: date)
        guard !all.isEmpty else { return 0 }
        return Double(all.filter { $0.isCompleted }.count) / Double(all.count)
    }

    func hasTasks(for date: Date) -> Bool {
        !tasks(for: date).isEmpty
    }

    // MARK: - Persistence

    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "tasks")
        }
    }

    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: "tasks"),
           let decoded = try? JSONDecoder().decode([TodoTask].self, from: data) {
            tasks = decoded
        } else {
            tasks = sampleTasks
        }
    }

    private var sampleTasks: [TodoTask] {
        [
            TodoTask(title: "Complete CS assignment", category: .school,   rewardValue: 20, dueDate: Date().startOfDay),
            TodoTask(title: "Morning workout",         category: .health,   rewardValue: 15, dueDate: Date().startOfDay),
            TodoTask(title: "Read for 30 minutes",    category: .school,   rewardValue: 10, dueDate: Date().startOfDay),
        ]
    }
}
