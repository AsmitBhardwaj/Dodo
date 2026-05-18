//
//  OnboardingComponents.swift
//  Dodo
//
//  Created by Asmit Bhardwaj on 17/05/26.
//

import SwiftUI

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
