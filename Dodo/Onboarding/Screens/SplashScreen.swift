//
//  SplashScreen.swift
//  Dodo
//
//  Created by Asmit Bhardwaj on 17/05/26.
//


import SwiftUI

struct SplashScreen: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {
                DodoLogoView(size: 80)

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
                onNext()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}