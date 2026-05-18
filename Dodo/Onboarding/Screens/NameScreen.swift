//
//  NameScreen.swift
//  Dodo
//
//  Created by Asmit Bhardwaj on 17/05/26.
//


import SwiftUI

struct NameScreen: View {
    @Bindable var state: OnboardingState
    let onNext: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {

            Spacer()

            VStack(alignment: .leading, spacing: 20) {
                Text("What should\nDodo call you?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.dodoOrange)
                    .lineSpacing(4)

                TextField("", text: $state.name)
                    .placeholder(when: state.name.isEmpty) {
                        Text("Name...")
                            .foregroundColor(.white.opacity(0.25))
                    }
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .padding(16)
                    .background(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                    )
                    .cornerRadius(14)
                    .focused($isFocused)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 24)

            Spacer()

            DodoButton(title: "Continue", disabled: !state.canAdvanceFromName) {
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
