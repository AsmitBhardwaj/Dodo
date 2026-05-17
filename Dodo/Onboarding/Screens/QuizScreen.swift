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
                "I keep starting strong, then quietly stopping",
                "I know exactly what to do. I just don't do it",
                "I'm done winging it. Done improvising my life",
                "I'm wasting too much time and I can feel it"
            ]
        ),
        (
            "Be honest. What's actually stopping you?",
            [
                "Motivation shows up, then quietly disappears",
                "Everything pulls my attention. My phone, my brain, everything",
                "I forget what I was working on within an hour",
                "I'm inconsistent and I've stopped pretending otherwise"
            ]
        ),
        (
            "If we talk in 3 months, what's changed?",
            [
                "I actually finished the things I started",
                "I showed up every single day. Even the bad ones",
                "I'm sleeping, eating, moving like an adult",
                "I built something real. Something I can point to"
            ]
        ),
        (
            "One bad day. What happens next?",
            [
                "One miss becomes three. Three becomes a week",
                "I beat myself up for a day, then claw my way back",
                "Honestly? I don't really notice until it's been a while",
                "I go twice as hard the next day to make up for it"
            ]
        ),
        (
            "When does your best work actually happen?",
            [
                "Locked in, no phone, hours at a time",
                "Quick focused hits scattered throughout the day",
                "Whenever the mood hits. Which is rarely",
                "The night before it's due. Always has been"
            ]
        ),
        (
            "Last 30 days. What pattern do you see?",
            [
                "All or nothing. Perfect week, then I disappear",
                "Steady but slow. I never go hard, never quit either",
                "Total chaos. Good days and bad days, no rhyme or reason",
                "Monday hero, Friday ghost. Every week, same story"
            ]
        ),
        (
            "Finishing something — what does it feel like?",
            [
                "Rare. I'm always 80% done with five things",
                "Good for about ten minutes, then I'm onto the next thing",
                "Honestly? I'm not sure I've ever felt actually done",
                "Depends. Sometimes it's everything. Sometimes it's nothing"
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
                    .font(.system(size: 26, weight: .bold))
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
                                .font(.system(size: 14, weight: .medium))
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