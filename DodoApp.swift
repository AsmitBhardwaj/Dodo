//
//  DodoApp.swift
//  Dodo - Life Gamification
//

import SwiftUI
import Combine

@main
struct DodoApp: App {
    @StateObject private var taskManager = TaskManager()
    @StateObject private var dodoManager = DodoManager()
    @StateObject private var stats = StatsManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(taskManager)
                .environmentObject(dodoManager)
                .environmentObject(stats)
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Root with splash

struct RootView: View {
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else {
                ContentView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: showSplash)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                showSplash = false
            }
        }
    }
}

// MARK: - Splash screen

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: CGFloat = 0
    @State private var glowOpacity: CGFloat = 0
    @State private var taglineOpacity: CGFloat = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Subtle orange radial glow behind logo
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#F97316").opacity(0.3), Color.clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 140
                    )
                )
                .frame(width: 280, height: 280)
                .opacity(glowOpacity)

            VStack(spacing: 20) {
                // Logo mark
                ZStack {
                    Circle()
                        .fill(Color(hex: "#F97316").opacity(0.15))
                        .frame(width: 110, height: 110)

                    Circle()
                        .strokeBorder(Color(hex: "#F97316"), lineWidth: 2)
                        .frame(width: 110, height: 110)

                    Text("🦤")
                        .font(.system(size: 52))
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                // App name + tagline
                VStack(spacing: 4) {
                    Text("dodo")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("don't go extinct")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "#F97316"))
                        .tracking(2)
                }
                .opacity(taglineOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                logoScale   = 1.0
                logoOpacity = 1.0
            }
            withAnimation(.easeIn(duration: 0.8).delay(0.3)) {
                glowOpacity    = 1.0
                taglineOpacity = 1.0
            }
        }
    }
}
