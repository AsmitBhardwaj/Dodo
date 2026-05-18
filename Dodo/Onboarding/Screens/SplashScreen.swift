//
//  SplashScreen.swift
//  Dodo
//
//  Created by Asmit Bhardwaj on 17/05/26.
//
import SwiftUI

struct SplashScreen: View {
    let onNext: () -> Void

    @State private var animateRings = false
    @State private var isTransitioning = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .stroke(Color.dodoOrange.opacity(0.10), lineWidth: 1)
                                .frame(width: 148, height: 148)
                                .scaleEffect(animateRings ? 1.35 : 1.0)
                                .opacity(animateRings ? 0 : 0.6)
                                .animation(
                                    .easeOut(duration: 2.0)
                                    .repeatForever(autoreverses: false)
                                    .delay(0.4),
                                    value: animateRings
                                )

                            Circle()
                                .stroke(Color.dodoOrange.opacity(0.18), lineWidth: 1)
                                .frame(width: 124, height: 124)
                                .scaleEffect(animateRings ? 1.3 : 1.0)
                                .opacity(animateRings ? 0 : 0.7)
                                .animation(
                                    .easeOut(duration: 2.0)
                                    .repeatForever(autoreverses: false)
                                    .delay(0.2),
                                    value: animateRings
                                )

                            Circle()
                                .stroke(Color.dodoOrange.opacity(0.30), lineWidth: 1.5)
                                .frame(width: 104, height: 104)
                                .scaleEffect(animateRings ? 1.2 : 1.0)
                                .opacity(animateRings ? 0 : 0.85)
                                .animation(
                                    .easeOut(duration: 2.0)
                                    .repeatForever(autoreverses: false),
                                    value: animateRings
                                )

                            DodoLogoView(size: 80)
                        }

                        Text("Dodo")
                            .font(.system(size: 42, weight: .black))
                            .foregroundColor(.dodoOrange)
                            .tracking(-1.5)

                        Text("Either you do it\nor you don't.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white.opacity(0.35))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }

                    Spacer()

                    DodoButton(title: "Let's go") {
                        guard !isTransitioning else { return }
                        isTransitioning = true
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }

                if isTransitioning {
                    let buttonCenterY = geo.size.height - 48 - 28

                    Circle()
                        .fill(Color.dodoOrange)
                        .frame(width: 60, height: 60)
                        .position(x: geo.size.width / 2, y: buttonCenterY)
                        .scaleEffect(35)
                        .animation(.easeIn(duration: 0.5), value: isTransitioning)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                                onNext()
                            }
                        }
                }
            }
            .onAppear {
                animateRings = true
            }
        }
        .ignoresSafeArea()
    }
}
