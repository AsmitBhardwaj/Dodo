import Foundation
import SwiftUI
import Combine

// MARK: - Stat Type

enum StatType: String, CaseIterable {
    case focus, mood, consistency

    var displayName: String {
        switch self {
        case .focus:       return "Focus"
        case .mood:        return "Mood"
        case .consistency: return "Consistency"
        }
    }

    var icon: String {
        switch self {
        case .focus:       return "bolt.fill"
        case .mood:        return "heart.fill"
        case .consistency: return "arrow.clockwise"
        }
    }

    var color: Color {
        switch self {
        case .focus:       return Color(hex: "#F97316") // orange
        case .mood:        return Color(hex: "#FF4D6D") // pink-red
        case .consistency: return Color(hex: "#22C55E") // green
        }
    }

    var taskHint: String {
        switch self {
        case .focus:       return "Log a school task to rebuild."
        case .mood:        return "Log a personal or social task."
        case .consistency: return "One health task. Right now."
        }
    }

    var relevantCategories: [TodoTask.TaskCategory] {
        switch self {
        case .focus:       return [.school]
        case .mood:        return [.personal, .social]
        case .consistency: return [.health]
        }
    }
}

// MARK: - DodoStat Model

struct DodoStat: Codable {
    var value: Double          // 0.0–1.0 current fill
    var ceiling: Double        // 0.0–1.0 max recoverable right now
    var lastBoostDate: Date    // last time a relevant task was logged
    var lastCeilingDropDate: Date

    init() {
        self.value = 1.0
        self.ceiling = 1.0
        self.lastBoostDate = Date()
        self.lastCeilingDropDate = Date()
    }
}

// MARK: - StatsManager

class StatsManager: ObservableObject {

    // Published stats
    @Published var focus: DodoStat
    @Published var mood: DodoStat
    @Published var consistency: DodoStat

    // Tuning constants
    private let decayPerHour: Double   = 0.07   // 7% per hour → dead in ~14h
    private let graceHours: Double     = 0.5    // 30-min grace period after task
    private let recoveryPerTask: Double = 0.20  // +20% per relevant task
    private let ceilingDrop: Double    = 0.15   // ceiling -15% per day at zero
    private let ceilingRise: Double    = 0.05   // ceiling +5% per healthy tick
    private let minCeiling: Double     = 0.25   // never fully unrecoverable

    private var decayTimer: Timer?
    private let saveKey = "dodo_stats_v2"

    init() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let saved = try? JSONDecoder().decode([String: DodoStat].self, from: data) {
            self.focus       = saved["focus"]       ?? DodoStat()
            self.mood        = saved["mood"]        ?? DodoStat()
            self.consistency = saved["consistency"] ?? DodoStat()
        } else {
            self.focus       = DodoStat()
            self.mood        = DodoStat()
            self.consistency = DodoStat()
        }

        recalculateFromBackground()
        startTimer()
    }

    // MARK: - Public API

    func taskCompleted(category: TodoTask.TaskCategory) {
        if StatType.focus.relevantCategories.contains(category)       { boost(&focus) }
        if StatType.mood.relevantCategories.contains(category)        { boost(&mood) }
        if StatType.consistency.relevantCategories.contains(category) { boost(&consistency) }
        save()
    }

    func recalculateFromBackground() {
        let now = Date()
        recalculate(&focus,       now: now)
        recalculate(&mood,        now: now)
        recalculate(&consistency, now: now)
        save()
    }

    // MARK: - Subtitle Logic (called from View)

    func subtitle(for type: StatType) -> String {
        let stat = self.stat(for: type)
        let cap  = Int(stat.ceiling * 100)

        // Dead
        if stat.value <= 0 {
            return "\(type.displayName) is gone. \(type.taskHint)"
        }

        // Critical — show countdown
        let hours = hoursUntilZero(stat)
        if hours < 2 {
            let mins = Int(hours * 60)
            return "Hits 0 in \(mins)m. \(type.taskHint)"
        }
        if hours < 6 {
            return "Drops to 0 in ~\(Int(hours))h. \(type.taskHint)"
        }

        // Ceiling damaged
        if stat.ceiling < 0.85 {
            return "Capped at \(cap)%. Consistent days rebuild it."
        }

        // Healthy — show ceiling reward message
        if stat.value >= stat.ceiling && stat.ceiling >= 0.95 {
            return "At full power. Keep it there."
        }

        return type.taskHint
    }

    func hoursUntilZero(_ stat: DodoStat) -> Double {
        guard stat.value > 0 else { return 0 }
        return stat.value / decayPerHour
    }

    func stat(for type: StatType) -> DodoStat {
        switch type {
        case .focus:       return focus
        case .mood:        return mood
        case .consistency: return consistency
        }
    }

    // MARK: - Private Mechanics

    private func boost(_ stat: inout DodoStat) {
        stat.value = min(stat.ceiling, stat.value + recoveryPerTask)
        stat.lastBoostDate = Date()
        // Healthy → slowly repair ceiling
        if stat.value >= 0.6 {
            stat.ceiling = min(1.0, stat.ceiling + ceilingRise)
        }
    }

    private func startTimer() {
        decayTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            guard let self else { return }
            let now = Date()
            self.tickDecay(&self.focus,       now: now)
            self.tickDecay(&self.mood,        now: now)
            self.tickDecay(&self.consistency, now: now)
            self.save()
        }
    }

    private func tickDecay(_ stat: inout DodoStat, now: Date) {
        let hoursSinceBoost = now.timeIntervalSince(stat.lastBoostDate) / 3600
        guard hoursSinceBoost > graceHours else { return }

        // Decay per minute
        let decayThisTick = decayPerHour / 60.0
        stat.value = max(0, stat.value - decayThisTick)

        // If at zero and a full day has passed since last ceiling drop → drop ceiling
        if stat.value <= 0 {
            let hoursSinceDrop = now.timeIntervalSince(stat.lastCeilingDropDate) / 3600
            if hoursSinceDrop >= 24 {
                stat.ceiling = max(minCeiling, stat.ceiling - ceilingDrop)
                stat.lastCeilingDropDate = now
            }
        }
    }

    private func recalculate(_ stat: inout DodoStat, now: Date) {
        let hoursSinceBoost = now.timeIntervalSince(stat.lastBoostDate) / 3600
        guard hoursSinceBoost > graceHours else { return }

        let billableHours = hoursSinceBoost - graceHours
        let totalDecay    = billableHours * decayPerHour
        stat.value        = max(0, stat.value - totalDecay)

        // Apply ceiling drops for days missed at zero
        if stat.value <= 0 {
            let daysMissed = Int(billableHours / 24)
            if daysMissed > 0 {
                let drops = min(Double(daysMissed), 4) // cap at 4 days of drops
                stat.ceiling = max(minCeiling, stat.ceiling - ceilingDrop * drops)
                stat.lastCeilingDropDate = now
            }
        }
    }

    private func save() {
        let dict: [String: DodoStat] = [
            "focus":       focus,
            "mood":        mood,
            "consistency": consistency
        ]
        if let data = try? JSONEncoder().encode(dict) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }
}

// MARK: - Color Hex Extension (add once to project)

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
