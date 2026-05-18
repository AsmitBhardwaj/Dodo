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

                // Logo at 1/4
                Text("Dodo")
                    .font(.system(size: 58, weight: .black))
                    .foregroundColor(.dodoOrange)
                    .tracking(-1.5)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.45)

                // Slogan at 2/4
                Text(" You do it or you don't.")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white.opacity(0.25))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.5)

                // Button at 3/4
                DodoButton(title: "LET'S START") {
                    onNext()
                }
                .padding(.horizontal, 24)
                .font(.system(size: 20, weight: .bold))
                .position(x: geo.size.width / 2, y: geo.size.height * 0.9)
            }
        }
        .ignoresSafeArea()
    }
}
