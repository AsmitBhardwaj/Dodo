//
//  UserType.swift
//  Dodo
//
//  Created by Asmit Bhardwaj on 17/05/26.
//
import Foundation

// MARK: - Radar Scores

struct RadarScores: Codable, Equatable {
    var focus: Double
    var consistency: Double
    var output: Double
    var recovery: Double

    static let neutral = RadarScores(focus: 50, consistency: 50, output: 50, recovery: 50)

    func distance(to other: RadarScores) -> Double {
        let df  = focus - other.focus
        let dc  = consistency - other.consistency
        let doo = output - other.output
        let dr  = recovery - other.recovery
        return (df * df + dc * dc + doo * doo + dr * dr).squareRoot()
    }
}

// MARK: - Type Rarity

enum TypeRarity: String, Codable {
    case common
    case uncommon
    case rare
    case legendary

    var displayName: String {
        return self.rawValue.capitalized
    }
}

// MARK: - Protocol Info

struct DodoProtocol {
    let codename: String
    let whyTheName: String
    let theProblem: String
    let whatWereDoing: [String]
    let focusAreas: [String]
    let thePromise: String
}

// MARK: - User Type

enum UserType: String, CaseIterable, Codable {
    case igniter
    case scholar
    case ghost
    case machine
    case architect
    case drifter

    var displayName: String {
        switch self {
        case .igniter:   return "The Igniter"
        case .scholar:   return "The Scholar"
        case .ghost:     return "The Ghost"
        case .machine:   return "The Machine"
        case .architect: return "The Architect"
        case .drifter:   return "The Drifter"
        }
    }

    var tagline: String {
        switch self {
        case .igniter:   return "Starts everything. Rarely lands the plane."
        case .scholar:   return "Knows everything. Ships nothing."
        case .ghost:     return "Great when you're here. You keep vanishing."
        case .machine:   return "Shows up every day. Never goes deep enough."
        case .architect: return "The plan is perfect. It's been in your head for months."
        case .drifter:   return "Busy every single day. Just not with the right things."
        }
    }

    var rarity: TypeRarity {
        switch self {
        case .machine, .drifter: return .common
        case .igniter:           return .uncommon
        case .scholar, .architect: return .rare
        case .ghost:             return .legendary
        }
    }

    var dodoProtocol: DodoProtocol {
        switch self {
        case .igniter:
            return DodoProtocol(
                codename: "Project: Zero",
                whyTheName: "Because your goal is to get your unfinished pile to zero. Not someday. Now.",
                theProblem: "You have more started things than finished ones. Always have.",
                whatWereDoing: [
                    "Limiting active tasks so you can't start new ones without closing old ones",
                    "Surfacing your open loops every single morning",
                    "Tracking completion rate, not just task count"
                ],
                focusAreas: ["Ship what you start", "Close the backlog", "Consistency over intensity"],
                thePromise: "In 30 days you'll have finished more than you did in the last 3 months."
            )

        case .scholar:
            return DodoProtocol(
                codename: "Project: Proof",
                whyTheName: "Knowing things doesn't count. Showing them does. This is about proving — to yourself and everyone else — that the knowledge goes somewhere.",
                theProblem: "You know more than almost anyone. You just never show it.",
                whatWereDoing: [
                    "Enforcing at least one Ship task every single day",
                    "No pure Sharpen days — input without output is just consumption",
                    "Making your output visible and trackable"
                ],
                focusAreas: ["Daily output", "Deadline discipline", "Knowledge into work"],
                thePromise: "In 30 days people will start to see what you're actually capable of."
            )

        case .ghost:
            return DodoProtocol(
                codename: "Project: Anchor",
                whyTheName: "You need something that holds you in place when you feel like drifting. An anchor doesn't stop you from moving — it stops you from disappearing entirely.",
                theProblem: "You're great when you're here. The problem is you keep vanishing.",
                whatWereDoing: [
                    "Making your daily minimum so small you can't justify skipping it",
                    "Activating the never miss twice rule hard — recovery speed is everything",
                    "Building non-negotiable daily anchors that don't depend on motivation"
                ],
                focusAreas: ["Daily anchors", "Recovery speed", "A floor you can't fall below"],
                thePromise: "In 30 days disappearing won't feel like an option anymore."
            )

        case .machine:
            return DodoProtocol(
                codename: "Project: Iceberg",
                whyTheName: "You're showing people the surface — the reps, the check-ins, the consistency. But there's no depth underneath. This program builds the part nobody sees.",
                theProblem: "You show up. You check boxes. You're not actually growing.",
                whatWereDoing: [
                    "Pushing Sharpen tasks into every week, non-negotiable",
                    "Flagging when you're coasting on easy Wrap tasks",
                    "Measuring depth of work, not just volume"
                ],
                focusAreas: ["Deep work sessions", "Learning that compounds", "Quality over volume"],
                thePromise: "In 30 days your consistency will actually mean something."
            )

        case .architect:
            return DodoProtocol(
                codename: "Project: Launch",
                whyTheName: "Everything you've been building in your head needs a runway. This program is that runway. It ends with something in the air.",
                theProblem: "The plan is perfect. It's been in your head for three months.",
                whatWereDoing: [
                    "Forcing short deadlines on every task you add",
                    "Flagging anything that has been sitting longer than 48 hours",
                    "Making shipping a daily habit, not a milestone"
                ],
                focusAreas: ["Done over perfect", "Shipping reps", "Kill planning paralysis"],
                thePromise: "In 30 days you'll have shipped something real. Not planned it. Shipped it."
            )

        case .drifter:
            return DodoProtocol(
                codename: "Project: Thread",
                whyTheName: "Right now your days are a pile of loose ends. This program pulls one thread all the way through — one priority, followed consistently, until it's done.",
                theProblem: "You're busy every single day. Just not with the right things.",
                whatWereDoing: [
                    "Enforcing category balance so nothing gets ignored for too long",
                    "Capping how much you can spread yourself in a single day",
                    "Teaching you to say no to yourself"
                ],
                focusAreas: ["Single priorities", "Category discipline", "Protect your attention"],
                thePromise: "In 30 days you'll know exactly what you're building — and actually be building it."
            )
        }
    }

    // Reference radar profile for euclidean distance matching
    var profile: RadarScores {
        switch self {
        case .igniter:   return RadarScores(focus: 70, consistency: 20, output: 90, recovery: 30)
        case .scholar:   return RadarScores(focus: 90, consistency: 55, output: 20, recovery: 50)
        case .ghost:     return RadarScores(focus: 35, consistency: 20, output: 35, recovery: 80)
        case .machine:   return RadarScores(focus: 40, consistency: 90, output: 70, recovery: 65)
        case .architect: return RadarScores(focus: 85, consistency: 40, output: 20, recovery: 25)
        case .drifter:   return RadarScores(focus: 35, consistency: 35, output: 40, recovery: 45)
        }
    }
}

