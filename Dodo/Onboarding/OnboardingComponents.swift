//
//  OnboardingComponents.swift
//  Dodo
//
//  Created by Asmit Bhardwaj on 17/05/26.
//

import SwiftUI

// MARK: - Dodo Logo

struct DodoLogoView: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.dodoOrange, lineWidth: size * 0.04)
                .frame(width: size, height: size)

            Path { path in
                let s = size * 0.6
                let ox = size / 2 - s / 2
                let oy = size / 2 - s / 2
                path.move(to: CGPoint(x: ox, y: oy + s * 0.5))
                path.addLine(to: CGPoint(x: ox + s * 0.35, y: oy + s))
                path.addLine(to: CGPoint(x: ox + s, y: oy))
            }
            .stroke(Color.dodoOrange, style: StrokeStyle(lineWidth: size * 0.06, lineCap: .round, lineJoin: .round))
        }
    }
}

// MARK: - Primary Button

struct DodoButton: View {
    let title: String
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(disabled ? .white.opacity(0.3) : .black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(disabled ? Color.white.opacity(0.08) : Color.dodoOrange)
                .cornerRadius(16)
        }
        .disabled(disabled)
        .animation(.easeInOut(duration: 0.2), value: disabled)
    }
}

// MARK: - Placeholder modifier

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: .leading) {
            if shouldShow {
                placeholder()
            }
            self
        }
    }
}
