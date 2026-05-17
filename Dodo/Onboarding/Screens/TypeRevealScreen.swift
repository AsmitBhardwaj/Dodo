//
//  TypeRevealScreen.swift
//  Dodo
//
//  Created by Asmit Bhardwaj on 17/05/26.
//


import SwiftUI

struct TypeRevealScreen: View {
    let state: OnboardingState
    let onNext: () -> Void

    var userType: UserType { state.computedType }
    var scores: RadarScores { state.computedScores }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Text("Your type is")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
                    .tracking(1.2)
                    .textCase(.uppercase)

                Text(userType.displayName)
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(.dodoOrange)
                    .tracking(-0.5)

                RadarView(scores: scores)
                    .frame(width: 200, height: 200)

                Text(userType.tagline)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)

                Text(userType.rarity.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            }

            Spacer()

            DodoButton(title: "See your program →") {
                onNext()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}