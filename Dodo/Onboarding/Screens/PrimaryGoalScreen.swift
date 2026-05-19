//
//  PrimaryGoalScreen.swift
//  Dodo
//
//  Created by Asmit Bhardwaj on 17/05/26.
//


import SwiftUI

struct PrimaryGoalScreen: View {
    @Bindable var state: OnboardingState
    let onNext: () -> Void

    let goals = ["Study & academics", "Work & career", "Health & fitness", "Personal Growth"]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 20) {
                Text("What's your\nprimary focus?")
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(.dodoOrange)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)

                VStack(spacing: 10) {
                    ForEach(goals, id: \.self) { goal in
                        Button {
                            state.primaryGoal = goal
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                onNext()
                            }
                        } label: {
                            Text(goal)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(state.primaryGoal == goal ? .dodoOrange : .white.opacity(0.75))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 18)
                                .background(Color.white.opacity(0.04))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            state.primaryGoal == goal
                                                ? Color.dodoOrange
                                                : Color.white.opacity(0.18),
                                            lineWidth: 1.5
                                        )
                                )
                                .cornerRadius(14)
                        }
                        .padding(.horizontal, 24)
                    }
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}
