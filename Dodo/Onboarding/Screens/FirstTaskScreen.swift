//
//  FirstTaskScreen.swift
//  Dodo
//
//  Created by Asmit Bhardwaj on 17/05/26.
//


import SwiftUI

struct FirstTaskScreen: View {
    @Bindable var state: OnboardingState
    let onNext: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add your first task")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.dodoOrange)

                    Text("You can't leave without one.")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.4))
                }

                TextField("", text: $state.firstTaskTitle)
                    .placeholder(when: state.firstTaskTitle.isEmpty) {
                        Text("What needs to get done?")
                            .foregroundColor(.white.opacity(0.25))
                    }
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(16)
                    .background(Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                    )
                    .cornerRadius(14)
                    .focused($isFocused)
                    .autocorrectionDisabled()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Category")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.3))
                        .tracking(1.2)
                        .textCase(.uppercase)

                    VStack(spacing: 8) {
                        ForEach(TodoTask.TaskCategory.allCases, id: \.self) { category in
                            Button {
                                state.firstTaskCategory = category
                            } label: {
                                HStack(spacing: 12) {
                                    Text(category.emoji)
                                        .font(.system(size: 18))

                                    Text(category.rawValue)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(
                                            state.firstTaskCategory == category
                                                ? .dodoOrange
                                                : .white.opacity(0.7)
                                        )

                                    Spacer()

                                    if state.firstTaskCategory == category {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(.dodoOrange)
                                    }
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(Color.white.opacity(0.04))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            state.firstTaskCategory == category
                                                ? Color.dodoOrange
                                                : Color.white.opacity(0.15),
                                            lineWidth: 1.5
                                        )
                                )
                                .cornerRadius(12)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            DodoButton(title: "Start →", disabled: !state.canAdvanceFromFirstTask) {
                onNext()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .onAppear {
            isFocused = true
        }
    }
}