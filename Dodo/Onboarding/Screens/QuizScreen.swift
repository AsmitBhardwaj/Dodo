//
//  QuizScreen.swift
//  Dodo
//
//  Created by Asmit Bhardwaj on 17/05/26.
//


import SwiftUI

struct QuizScreen: View {
    @Bindable var state: OnboardingState
    let questionIndex: Int
    let onNext: () -> Void

    private let questions: [(question: String, options: [String])] = [
        (
            "What brought you to Dodo?",
            [
                "I keep starting strong but I stop when gas runs out",
                "I know what I need to do. I just do not do it.",
                "I plan everything but I stop at the execution phase.",
                "I'm wasting too much time and I know it."
            ]
        ),
        (
            "Why is that happening?",
            [
                "I work on motivation and not on discpline.",
                "I am too distracted and unfocused to get anything done",
                "I confuse being busy with being productive",
                "I'm inconsistent and I've stopped taking accountability."
            ]
        ),
        (
            "When do you do your best work?",
            [
                "Early Mornings",
                "Afternoon.",
                "Evenings.",
                "Late Nights."
            ]
        ),
        (
            "What is a good day for you?",
            [
                "I finish everything I planned to finish.",
                "I made progress on most things.",
                "I stayed locked in without getting distracted",
                "I felt in control of my time and output."
            ]
        ),
        (
            "What does your ideal morning look like?",
            [
                "Woke up early, worked out and got some work done.",
                "Woke up, got my coffee and plan out the whole day.",
                "Woke up and started working directly.",
                "Depends on the day."
            ]
        ),
        (
            "How do you handle a packed schedule?",
            [
                "I prioritise the important things.",
                "I break it into small pieces.",
                "I stay up late and rawdog it regardless.",
                "I go with the flow."
            ]
        ),
        (
            "What's one thing you want Dodo to help you with?",
            [
                "I want to use it to stop procrastination.",
                "I want a system that I can adhere to daily.",
                "I want to use Dodo to build discipline.",
                "I want to make better use of the time I already have."
            ]
        )
    ]

    var currentQuestion: (question: String, options: [String]) {
        questions[questionIndex]
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 16) {
                Text(currentQuestion.question)
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(.dodoOrange)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)

                VStack(spacing: 10) {
                    ForEach(Array(currentQuestion.options.enumerated()), id: \.offset) { index, option in
                        Button {
                            state.quizAnswers[questionIndex] = index
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                onNext()
                            }
                        } label: {
                            Text(option)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(
                                    state.quizAnswers[questionIndex] == index
                                        ? .dodoOrange
                                        : .white.opacity(0.75)
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 14)
                                .padding(.horizontal, 18)
                                .background(Color.white.opacity(0.04))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            state.quizAnswers[questionIndex] == index
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
