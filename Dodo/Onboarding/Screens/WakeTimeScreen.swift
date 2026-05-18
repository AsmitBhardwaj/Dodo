//
//  WakeTimeScreen.swift
//  Dodo
//
//  Created by Asmit Bhardwaj on 17/05/26.
//


import SwiftUI

struct WakeTimeScreen: View {
    @Bindable var state: OnboardingState
    let onNext: () -> Void

    let times = ["<7:00 AM", "8:00 AM", "9:00 AM", "10:00 AM", "10:00 AM<"]

    var body: some View {
        VStack(spacing: 0) {

            Spacer()

            VStack(alignment: .leading, spacing: 20) {
                Text("What time do\nyou wake up, \(state.name)?")
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(.dodoOrange)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)

                VStack(spacing: 10) {
                    ForEach(times, id: \.self) { time in
                        Button {
                            state.wakeTime = time
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                onNext()
                            }
                        } label: {
                            Text(time)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(state.wakeTime == time ? .dodoOrange : .white.opacity(0.75))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white.opacity(0.04))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            state.wakeTime == time
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
