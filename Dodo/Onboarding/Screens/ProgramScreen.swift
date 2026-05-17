//
//  ProgramScreen.swift
//  Dodo
//
//  Created by Asmit Bhardwaj on 17/05/26.
//


import SwiftUI

struct ProgramScreen: View {
    let state: OnboardingState
    let onNext: () -> Void

    var userType: UserType { state.computedType }
    var protocol_: DodoProtocol { userType.dodoProtocol }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    Spacer().frame(height: 60)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your program")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.35))
                            .tracking(1.2)
                            .textCase(.uppercase)

                        Text(protocol_.codename)
                            .font(.system(size: 32, weight: .black))
                            .foregroundColor(.dodoOrange)
                            .tracking(-0.5)

                        Text(protocol_.whyTheName)
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.5))
                            .lineSpacing(5)
                    }

                    Divider()
                        .background(Color.white.opacity(0.1))

                    VStack(alignment: .leading, spacing: 12) {
                        Text("What we're doing")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.35))
                            .tracking(1.2)
                            .textCase(.uppercase)

                        ForEach(protocol_.whatWereDoing, id: \.self) { item in
                            HStack(alignment: .top, spacing: 12) {
                                Text("→")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.dodoOrange)

                                Text(item)
                                    .font(.system(size: 15))
                                    .foregroundColor(.white.opacity(0.75))
                                    .lineSpacing(4)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Focus areas")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.35))
                            .tracking(1.2)
                            .textCase(.uppercase)

                        HStack(spacing: 8) {
                            ForEach(protocol_.focusAreas, id: \.self) { area in
                                Text(area)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.dodoOrange.opacity(0.85))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.dodoOrange.opacity(0.35), lineWidth: 1)
                                    )
                            }
                        }
                    }

                    Divider()
                        .background(Color.white.opacity(0.1))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("The promise")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.35))
                            .tracking(1.2)
                            .textCase(.uppercase)

                        Text(protocol_.thePromise)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.dodoOrange)
                            .lineSpacing(5)
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 24)
            }

            DodoButton(title: "Let's build it →") {
                onNext()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}