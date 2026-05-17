//
//  OnboardingState.swift
//  Dodo
//
//  Created by Asmit Bhardwaj on 17/05/26.
//


import Foundation
import Observation

@Observable
final class OnboardingState {
    
    // User inputs
    var name: String = ""
    var wakeTime: String = ""
    var quizAnswers: [Int?] = Array(repeating: nil, count: 7)
    var firstTaskTitle: String = ""
    var firstTaskCategory: TodoTask.TaskCategory? = nil
    var firstTaskDuration: TodoTask.TaskDuration = .short
    
    // Quiz answer deltas
    // Each delta adjusts focus/consistency/output/recovery from baseline 50
    private let answerDeltas: [[RadarScores]] = [
        // Q1 - What brought you to Dodo?
        [
            RadarScores(focus: 0, consistency: -15, output: -15, recovery: 0),
            RadarScores(focus: 10, consistency: 0, output: -10, recovery: 0),
            RadarScores(focus: 0, consistency: 15, output: 0, recovery: 5),
            RadarScores(focus: -10, consistency: 0, output: 15, recovery: 0)
        ],
        // Q2 - What's actually stopping you?
        [
            RadarScores(focus: 0, consistency: -15, output: 0, recovery: -20),
            RadarScores(focus: -25, consistency: 0, output: 0, recovery: 0),
            RadarScores(focus: 0, consistency: -20, output: -10, recovery: 0),
            RadarScores(focus: 0, consistency: -20, output: 0, recovery: 0)
        ],
        // Q3 - If we talk in 3 months, what's changed?
        [
            RadarScores(focus: 0, consistency: 0, output: 25, recovery: 0),
            RadarScores(focus: 0, consistency: 25, output: 0, recovery: 0),
            RadarScores(focus: 0, consistency: 10, output: 0, recovery: 20),
            RadarScores(focus: 15, consistency: 0, output: 20, recovery: 0)
        ],
        // Q4 - One bad day. What happens next?
        [
            RadarScores(focus: 0, consistency: -20, output: 0, recovery: -25),
            RadarScores(focus: 0, consistency: 0, output: 0, recovery: 20),
            RadarScores(focus: -10, consistency: -10, output: 0, recovery: 0),
            RadarScores(focus: 0, consistency: 0, output: 15, recovery: 5)
        ],
        // Q5 - When does your best work actually happen?
        [
            RadarScores(focus: 25, consistency: 0, output: 0, recovery: 0),
            RadarScores(focus: -5, consistency: 10, output: 0, recovery: 0),
            RadarScores(focus: -10, consistency: -20, output: 0, recovery: 0),
            RadarScores(focus: 0, consistency: -20, output: 20, recovery: 0)
        ],
        // Q6 - Last 30 days. What pattern do you see?
        [
            RadarScores(focus: 0, consistency: -25, output: 10, recovery: 0),
            RadarScores(focus: 0, consistency: 25, output: -10, recovery: 0),
            RadarScores(focus: -10, consistency: -20, output: 0, recovery: 0),
            RadarScores(focus: 0, consistency: -15, output: 0, recovery: -10)
        ],
        // Q7 - Finishing something - what does it feel like?
        [
            RadarScores(focus: 10, consistency: 0, output: -20, recovery: 0),
            RadarScores(focus: 0, consistency: 10, output: 20, recovery: 0),
            RadarScores(focus: 0, consistency: -10, output: -25, recovery: 0),
            RadarScores(focus: 5, consistency: 0, output: 0, recovery: -10)
        ]
    ]
    
    // Computed: current radar scores based on quiz answers
    var computedScores: RadarScores {
        var focus: Double = 50
        var consistency: Double = 50
        var output: Double = 50
        var recovery: Double = 50
        
        for (questionIndex, answerIndex) in quizAnswers.enumerated() {
            guard let answerIndex = answerIndex else {
                continue
            }
            guard questionIndex < answerDeltas.count else {
                continue
            }
            guard answerIndex < answerDeltas[questionIndex].count else {
                continue
            }
            
            let delta = answerDeltas[questionIndex][answerIndex]
            focus += delta.focus
            consistency += delta.consistency
            output += delta.output
            recovery += delta.recovery
        }
        
        return RadarScores(
            focus: clamp(focus),
            consistency: clamp(consistency),
            output: clamp(output),
            recovery: clamp(recovery)
        )
    }
    
    // Computed: matched user type based on scores
    var computedType: UserType {
        let scores = computedScores
        var bestType: UserType = .drifter
        var bestDistance = Double.infinity
        
        for type in UserType.allCases {
            let distance = scores.distance(to: type.profile)
            if distance < bestDistance {
                bestDistance = distance
                bestType = type
            }
        }
        
        return bestType
    }
    
    // Validation helpers
    var canAdvanceFromName: Bool {
        return !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var canAdvanceFromWakeTime: Bool {
        return !wakeTime.isEmpty
    }
    
    var canAdvanceFromFirstTask: Bool {
        let titleOk = !firstTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty
        let categoryOk = firstTaskCategory != nil
        return titleOk && categoryOk
    }
    
    private func clamp(_ value: Double) -> Double {
        return max(0, min(100, value))
    }
}
