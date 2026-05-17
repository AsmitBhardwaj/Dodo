//
//  GemUnlockScreen.swift
//  Dodo
//
//  Created by Asmit Bhardwaj on 17/05/26.
//


import SwiftUI

struct GemUnlockScreen: View {
    let state: OnboardingState
    let onFinish: () -> Void

    var userType: UserType { state.computedType }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                GemIconView()
                    .frame(width: 110, height: 110)

                VStack(spacing: 6) {
                    Text("You unlocked")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.35))
                        .tracking(1.2)
                        .textCase(.uppercase)

                    Text(userType.displayName)
                        .font(.system(size: 30, weight: .black))
                        .foregroundColor(.dodoOrange)
                        .tracking(-0.5)

                    Text(userType.rarity.displayName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.35))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 5)
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }

                Text(userType.tagline)
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.45))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 36)

                VStack(spacing: 4) {
                    Text("Current owner")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.25))

                    Text(state.name.isEmpty ? "You" : state.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.dodoOrange.opacity(0.7))
                }
            }

            Spacer()

            DodoButton(title: "You're in. Let's go →") {
                onFinish()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

// MARK: - Gem Icon

struct GemIconView: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let cx = w / 2

            let topLeft = CGPoint(x: cx - w * 0.32, y: h * 0.18)
            let topRight = CGPoint(x: cx + w * 0.32, y: h * 0.18)
            let midLeft = CGPoint(x: 0, y: h * 0.42)
            let midRight = CGPoint(x: w, y: h * 0.42)
            let bottom = CGPoint(x: cx, y: h * 0.95)
            let topMidLeft = CGPoint(x: cx - w * 0.1, y: h * 0.18)
            let topMidRight = CGPoint(x: cx + w * 0.1, y: h * 0.18)
            let midCenter = CGPoint(x: cx, y: h * 0.42)

            var outline = Path()
            outline.move(to: topLeft)
            outline.addLine(to: topRight)
            outline.addLine(to: midRight)
            outline.addLine(to: bottom)
            outline.addLine(to: midLeft)
            outline.closeSubpath()

            context.stroke(outline, with: .color(.dodoOrange), lineWidth: 2.5)

            var topLine = Path()
            topLine.move(to: midLeft)
            topLine.addLine(to: midRight)
            context.stroke(topLine, with: .color(.dodoOrange), lineWidth: 2)

            for pt in [topMidLeft, topMidRight] {
                var facet = Path()
                facet.move(to: pt)
                facet.addLine(to: midCenter)
                context.stroke(facet, with: .color(.dodoOrange.opacity(0.4)), lineWidth: 1.5)
            }

            var leftFacet = Path()
            leftFacet.move(to: topLeft)
            leftFacet.addLine(to: midCenter)
            context.stroke(leftFacet, with: .color(.dodoOrange.opacity(0.3)), lineWidth: 1)

            var rightFacet = Path()
            rightFacet.move(to: topRight)
            rightFacet.addLine(to: midCenter)
            context.stroke(rightFacet, with: .color(.dodoOrange.opacity(0.3)), lineWidth: 1)
        }
    }
}