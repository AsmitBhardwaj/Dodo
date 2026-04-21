//
//  Task.swift
//  Dodo - Life Gamification
//

import Foundation
import Combine

struct TodoTask: Identifiable, Codable {
    var id = UUID()
    var title: String
    var category: TaskCategory
    var isCompleted: Bool = false
    var completedDate: Date?
    var rewardValue: Int

    enum TaskCategory: String, Codable, CaseIterable {
        // "School" is front and center — it's the retention moat
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

class TaskManager: ObservableObject {
    @Published var tasks: [TodoTask] = []

    init() {
        loadTasks()
    }

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
            TodoTask(title: "Complete assignment",   category: .school,   rewardValue: 20),
            TodoTask(title: "Morning workout",        category: .health,   rewardValue: 15),
            TodoTask(title: "Read for 30 minutes",   category: .school,   rewardValue: 10),
        ]
    }
}
