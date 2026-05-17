//
//  CategoryScreen.swift
//  Dodo
//
//  Created by Asmit Bhardwaj on 17/05/26.
//


import SwiftUI

struct CategoryScreen: View {
    let category: TodoTask.TaskCategory
    let isLast: Bool
    let onNext: () -> Void

    private var examples: [String] {
        switch category {
        case .ship:    return ["CS assignments", "Essays", "Project milestones", "Submissions"]
        case .sharpen: return ["Textbook chapters", "Exam prep", "LeetCode", "Lectures"]
        case .train:   return ["Gym & runs", "Meal prep", "Sleep", "Hydration"]
        case .wrap:    return ["Emails", "Scheduling", "Admin", "Overdue stuff"]
        }
    }

    private var description: String {
        switch category {
        case .ship:    return "Tasks with a deadline. Build it, submit it, send it."
        case .sharpen: return "Input that compounds. Reading, studying, learning."
        case .train:   return "Your body is infrastructure. Ignore it, everything suffers."
        case .wrap:    return "Closing open loops. The things nagging at you."
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 20) {
                Text(category.emoji)
                    .font(.system(size: 52))

                Text(category.rawValue)
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(.dodoOrange)
                    .tracking(-0.5)

                Text(description)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.55))
                    .lineSpacing(5)

                Spacer().frame(height: 4)

                Text("Examples")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.3))
                    .tracking(1.2)
                    .textCase(.uppercase)

                HStack(spacing: 8) {
                    ForEach(examples, id: \.self) { example in
                        Text(example)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.dodoOrange.opacity(0.7))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .overlay(
                                Capsule()
                                    .stroke(Color.dodoOrange.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            DodoButton(title: isLast ? "Got it →" : "Next →") {
                onNext()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}