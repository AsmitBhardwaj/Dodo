//
//  Dodo.swift
//  Dodo
//
//  Personal growth stats — Focus, Mood, Consistency.
//  These are YOUR stats, not a pet's.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Stats Model

struct DodoStats: Codable {
    /// Focus: how locked-in you are. Rises with task completions, drifts down with inactivity.
    var focus: Double = 100.0
    /// Mood: your motivation level. Any completion gives a boost.
    var mood: Double = 100.0
    /// Consistency: your health/routine score. Boosted by Health-category tasks.
    var consistency: Double = 100.0

    var level: Int = 1
    var totalTasksCompleted: Int = 0
    var currentStreak: Int = 0
    var lastActiveDate: Date = Date()

    // MARK: Computed

    var averageStat: Double {
        (focus + mood + consistency) / 3
    }

    var statusMessage: String {
        switch averageStat {
        case 80...100: return "You're in the zone"
        case 60..<80:  return "Doing well, keep going"
        case 40..<60:  return "Build some momentum"
        case 20..<40:  return "Time to get back on track"
        default:       return "Let's get moving"
        }
    }

    var moodEmoji: String {
        switch averageStat {
        case 80...100: return "🔥"
        case 60..<80:  return "💪"
        case 40..<60:  return "😐"
        case 20..<40:  return "😔"
        default:       return "😴"
        }
    }

    var xpToNextLevel: Int {
        let thresholds = [10, 25, 45, 70, 100, 140, 190, 250, 320, 400]
        let idx = min(level - 1, thresholds.count - 1)
        let current = idx > 0 ? thresholds[idx - 1] : 0
        let next = thresholds[idx]
        return max(0, next - totalTasksCompleted + current)
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
        recalculateDecayOnForeground()
    }

    // MARK: - Foreground Decay
    // Focus and mood naturally drift if you haven't been active.
    // Called when app comes to foreground.
    func recalculateDecayOnForeground() {
        let hoursSinceActive = Date().timeIntervalSince(stats.lastActiveDate) / 3600
        guard hoursSinceActive > 6 else { return }

        let decayHours = hoursSinceActive - 6
        let focusDecay   = min(decayHours * 5, stats.focus)
        let moodDecay    = min(decayHours * 3, stats.mood)

        stats.focus = max(0, stats.focus - focusDecay)
        stats.mood  = max(0, stats.mood  - moodDecay)
        saveStats()
    }

    // MARK: - Task Completion (called from TaskCard)

    /// Call this when any task is completed.
    func taskCompleted(amount: Int) {
        stats.focus    = min(100, stats.focus + Double(amount))
        stats.mood     = min(100, stats.mood  + Double(amount) * 0.5)
        stats.totalTasksCompleted += 1
        stats.currentStreak += 1
        stats.lastActiveDate = Date()
        checkLevelUp()
        saveStats()
    }

    /// Call this when a Health-category task is completed.
    func healthTaskCompleted(amount: Int) {
        stats.consistency = min(100, stats.consistency + Double(amount))
        taskCompleted(amount: amount)
    }

    // MARK: - Private

    private func checkLevelUp() {
        let thresholds = [10, 25, 45, 70, 100, 140, 190, 250, 320, 400]
        let newLevel = (thresholds.firstIndex(where: { stats.totalTasksCompleted < $0 }) ?? thresholds.count) + 1
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
