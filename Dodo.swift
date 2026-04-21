//
//  Dodo.swift
//  Dodo - Life Gamification
//

import Foundation
import SwiftUI
import Combine

struct DodoStats: Codable {
    var hunger: Double = 100.0 // 0-100
    var happiness: Double = 100.0 // 0-100
    var health: Double = 100.0 // 0-100
    var level: Int = 1
    var totalTasksCompleted: Int = 0
    var lastFedDate: Date = Date()
    
    var moodEmoji: String {
        let average = (hunger + happiness + health) / 3
        switch average {
        case 80...100:
            return "😊"
        case 60..<80:
            return "🙂"
        case 40..<60:
            return "😐"
        case 20..<40:
            return "😟"
        default:
            return "😢"
        }
    }
    
    var statusMessage: String {
        let average = (hunger + happiness + health) / 3
        switch average {
        case 80...100:
            return "Dodo is thriving!"
        case 60..<80:
            return "Dodo is doing well"
        case 40..<60:
            return "Dodo needs attention"
        case 20..<40:
            return "Dodo is struggling"
        default:
            return "Dodo needs help!"
        }
    }
}

class DodoManager: ObservableObject {
    @Published var stats: DodoStats
    private var timer: Timer?
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "dodoStats"),
           let decoded = try? JSONDecoder().decode(DodoStats.self, from: data) {
            self.stats = decoded
        } else {
            self.stats = DodoStats()
        }
        
        startDecayTimer()
    }
    
    func feedDodo(amount: Int) {
        stats.hunger = min(100, stats.hunger + Double(amount))
        stats.happiness = min(100, stats.happiness + Double(amount) * 0.5)
        stats.totalTasksCompleted += 1
        
        // Level up every 10 tasks
        if stats.totalTasksCompleted % 10 == 0 {
            stats.level += 1
        }
        
        stats.lastFedDate = Date()
        saveStats()
    }
    
    func completeHealthTask(amount: Int) {
        stats.health = min(100, stats.health + Double(amount))
        feedDodo(amount: amount)
    }
    
    private func startDecayTimer() {
        // Decrease stats slowly over time (every hour)
        timer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.applyDecay()
        }
    }
    
    private func applyDecay() {
        let hoursSinceLastFed = Date().timeIntervalSince(stats.lastFedDate) / 3600
        
        if hoursSinceLastFed > 6 { // Start decaying after 6 hours
            stats.hunger = max(0, stats.hunger - 5)
            stats.happiness = max(0, stats.happiness - 3)
        }
        
        saveStats()
    }
    
    private func saveStats() {
        if let encoded = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(encoded, forKey: "dodoStats")
        }
    }
}
