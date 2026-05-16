//
//  GemsView.swift
//  Dodo
//
//  Created by Asmit Bhardwaj on 15/05/26.
//


//
//  GemsView.swift
//  Dodo
//

import SwiftUI

struct GemsView: View {
    @EnvironmentObject var dodoManager: DodoManager

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(dodoManager.stats.gems.filter { $0.isUnlocked }.count) of 10 unlocked")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.dodoOrange)
                        Text("Your collection.")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    // Gem grid
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(dodoManager.stats.gems) { gem in
                            GemCard(gem: gem)
                        }
                    }
                    .padding(.horizontal, 16)

                    // Next unlock hint
                    if let next = dodoManager.stats.gems.first(where: { !$0.isUnlocked }) {
                        NextGemCard(gem: next, dodoManager: dodoManager)
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 32)
            }
            .background(Color.black)
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Gem Card

struct GemCard: View {
    let gem: Gem

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(gem.isUnlocked ? Color.white.opacity(0.07) : Color.white.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(gem.isUnlocked ? Color.dodoOrange.opacity(0.4) : Color.white.opacity(0.06), lineWidth: 0.5)
                    )

                VStack(spacing: 6) {
                    Text(gem.isUnlocked ? gemEmoji(gem.id) : "🔒")
                        .font(.system(size: 32))
                        .opacity(gem.isUnlocked ? 1 : 0.3)

                    Text(gem.id)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(gem.isUnlocked ? .white : Color.white.opacity(0.25))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 8)
            }
        }
    }

    private func gemEmoji(_ id: String) -> String {
        switch id {
        case "Eureka":           return "🤍"
        case "Golden Jubilee":   return "💛"
        case "Dresden Green":    return "💚"
        case "Black Orlov":      return "🖤"
        case "Koh-i-Noor":       return "🤍"
        case "Oppenheimer Blue": return "💙"
        case "Hope Diamond":     return "🔵"
        case "Pink Star":        return "🩷"
        case "Cullinan":         return "💎"
        case "Moussaieff Red":   return "❤️"
        default:                 return "💎"
        }
    }
}

// MARK: - Next Gem Card

struct NextGemCard: View {
    let gem: Gem
    let dodoManager: DodoManager

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("NEXT GEM")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(.dodoOrange)
                .tracking(0.8)

            Text(gem.id)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.white)

            Text(unlockDescription(gem.id))
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(Color.white.opacity(0.4))
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.dodoOrange.opacity(0.2), lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func unlockDescription(_ id: String) -> String {
        switch id {
        case "Eureka":           return "Complete your first task."
        case "Golden Jubilee":   return "Reach 25 reps."
        case "Dresden Green":    return "Maintain a 7-day streak."
        case "Black Orlov":      return "Reach 100 reps."
        case "Koh-i-Noor":       return "Maintain a 14-day streak."
        case "Oppenheimer Blue": return "Reach 300 reps."
        case "Hope Diamond":     return "Maintain a 30-day streak."
        case "Pink Star":        return "Reach 500 reps and a 30-day streak."
        case "Cullinan":         return "Reach 1,000 reps."
        case "Moussaieff Red":   return "Reach 2,000 reps and a 66-day streak. Almost nobody will."
        default:                 return ""
        }
    }
}

#Preview {
    GemsView()
        .environmentObject(DodoManager())
        .preferredColorScheme(.dark)
}
