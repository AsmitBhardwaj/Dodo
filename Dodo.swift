//
//  Dodo.swift
//  Dodo - Life Gamification
//
 
import Foundation
import SwiftUI
import Combine
 
struct DodoStats: Codable {
    var hunger: Double = 100.0      // 0–100
    var happiness: Double = 100.0   // 0–100
    var health: Double = 100.0      // 0–100
    var level: Int = 1
    var totalTasksCompleted: Int = 0
    var lastFedDate: Date = Date()
 
    var moodEmoji: String {
        switch averageStat {
        case 80...100: return "😊"
        case 60..<80:  return "🙂"
        case 40..<60:  return "😐"
        case 20..<40:  return "😟"
        default:       return "😢"
        }
    }
 
    var statusMessage: String {
        switch averageStat {
        case 80...100: return "Dodo is thriving!"
        case 60..<80:  return "Dodo is doing well"
        case 40..<60:  return "Dodo needs attention"
        case 20..<40:  return "Dodo is struggling"
        default:       return "Dodo needs help!"
        }
    }
 
    private var averageStat: Double {
        (hunger + happiness + health) / 3
    }
}
 
class DodoManager: ObservableObject {
    @Published var stats: DodoStats
 
    init() {
        if let data = UserDefaults.standard.data(forKey: "dodoStats"),
           let decoded = try? JSONDecoder().decode(DodoStats.self, from: data) {
            self.stats = decoded
        } else {
            self.stats = DodoStats()
        }
 
        // Apply any decay that accumulated while the app was closed
        recalculateDecayOnForeground()
    }
 
    // MARK: - Called from ContentView on foreground transition
    // Replaces the Timer approach — calculates total decay based on
    // how many hours have passed since the app was last active.
    func recalculateDecayOnForeground() {
        let hoursSinceLastFed = Date().timeIntervalSince(stats.lastFedDate) / 3600
 
        guard hoursSinceLastFed > 6 else { return } // Grace period
 
        let decayHours = hoursSinceLastFed - 6
        let hungerDecay   = min(decayHours * 5,  stats.hunger)
        let happinessDecay = min(decayHours * 3, stats.happiness)
 
        stats.hunger    = max(0, stats.hunger    - hungerDecay)
        stats.happiness = max(0, stats.happiness - happinessDecay)
        saveStats()
    }
 
    // MARK: - Task Completion
 
    func feedDodo(amount: Int) {
        stats.hunger    = min(100, stats.hunger    + Double(amount))
        stats.happiness = min(100, stats.happiness + Double(amount) * 0.5)
        stats.totalTasksCompleted += 1
        checkLevelUp()
        stats.lastFedDate = Date()
        saveStats()
    }
 
    func completeHealthTask(amount: Int) {
        stats.health = min(100, stats.health + Double(amount))
        feedDodo(amount: amount)
    }
 
    // MARK: - Private
 
    private func checkLevelUp() {
        // Level threshold: 10 tasks for L2, 25 for L3, 45 for L4, etc.
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
