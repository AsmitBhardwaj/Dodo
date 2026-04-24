//
//  Dodo.swift
//  Dodo
//
//  Focus, Mood, Consistency are now COMPUTED from real task data.
//  DodoStats only stores what cannot be derived: level, streak, total count.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Stored Stats (only what can't be derived)

struct DodoStats: Codable {
    var level: Int = 1
    var totalTasksCompleted: Int = 0
    var currentStreak: Int = 0
    var lastActiveDate: Date = Date()

    var xpToNextLevel: Int {
        let thresholds = [10, 25, 45, 70, 100, 140, 190, 250, 320, 400]
        let idx = min(level - 1, thresholds.count - 1)
        let prev = idx > 0 ? thresholds[idx - 1] : 0
        let next = thresholds[idx]
        return max(0, next - totalTasksCompleted + prev)
    }
}

// MARK: - Manager

class DodoManager: ObservableObject {
    @Published var stats: DodoStats

    init() {
        if let data = UserDefaults.standard.data(forKey: "dodoStats"),
           let decoded = try? JSONDecoder().decode(DodoStats.self, from: data) {
            self.stats = decoded
        } else {
            self.stats = DodoStats()
        }
    }

    // MARK: - Real Computed Stats

    /// Focus = today's task completion rate (0-100).
    /// If no tasks today yet, falls back to yesterday.
    /// Honest: starts at 0% and you earn it through the day.
    func focus(from taskManager: TaskManager) -> Double {
        let today = Date().startOfDay
        if taskManager.hasTasks(for: today) {
            return taskManager.progress(for: today) * 100
        }
        let cal = Calendar.current
        guard let yesterday = cal.date(byAdding: .day, value: -1, to: today),
              taskManager.hasTasks(for: yesterday) else { return 0 }
        return taskManager.progress(for: yesterday) * 100
    }

    /// Mood = weighted completion trend of the last 3 days.
    /// Recent days count more. Reflects momentum, not just today.
    /// No history = 50 (neutral, not a fake 100).
    func mood(from taskManager: TaskManager) -> Double {
        let cal = Calendar.current
        let weights: [(Int, Double)] = [(-1, 0.5), (-2, 0.3), (-3, 0.2)]
        var weightedTotal: Double = 0
        var usedWeight: Double = 0

        for (offset, weight) in weights {
            guard let date = cal.date(byAdding: .day, value: offset,
                                      to: Date().startOfDay),
                  taskManager.hasTasks(for: date) else { continue }
            weightedTotal += taskManager.progress(for: date) * weight
            usedWeight += weight
        }

        guard usedWeight > 0 else { return 50 }
        return (weightedTotal / usedWeight) * 100
    }

    /// Consistency = average completion rate over the last 7 days.
    /// Days with no tasks are excluded — not penalised.
    func consistency(from taskManager: TaskManager) -> Double {
        let cal = Calendar.current
        var total: Double = 0
        var days = 0

        for i in 0..<7 {
            guard let date = cal.date(byAdding: .day, value: -i,
                                      to: Date().startOfDay),
                  taskManager.hasTasks(for: date) else { continue }
            total += taskManager.progress(for: date)
            days += 1
        }

        guard days > 0 else { return 0 }
        return (total / Double(days)) * 100
    }

    /// Status message derived from consistency — the most honest signal.
    func statusMessage(from taskManager: TaskManager) -> String {
        switch consistency(from: taskManager) {
        case 80...100: return "You're in the zone"
        case 60..<80:  return "Doing well, keep going"
        case 40..<60:  return "Build some momentum"
        case 20..<40:  return "Time to get back on track"
        default:       return "Let's get moving"
        }
    }

    // MARK: - Task Completion

    func taskCompleted(amount: Int) {
        stats.totalTasksCompleted += 1
        stats.currentStreak += 1
        stats.lastActiveDate = Date()
        checkLevelUp()
        saveStats()
    }

    func healthTaskCompleted(amount: Int) {
        taskCompleted(amount: amount)
    }

    func resetStreak() {
        stats.currentStreak = 0
        saveStats()
    }

    // MARK: - Private

    private func checkLevelUp() {
        let thresholds = [10, 25, 45, 70, 100, 140, 190, 250, 320, 400]
        let newLevel = (thresholds.firstIndex(where: {
            stats.totalTasksCompleted < $0
        }) ?? thresholds.count) + 1
        if newLevel > stats.level {
            stats.level = newLevel
        }
    }

    private func saveStats() {
        if let encoded = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(encoded, forKey: "dodoStats")
        }
    }
}
