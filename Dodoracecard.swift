import SwiftUI

// MARK: - Dodo Race Card (Today Screen)

struct DodoRaceCard: View {
    let userRate: Double    // 0.0–1.0
    let ghostRate: Double   // 0.0–1.0

    private var isAhead: Bool  { userRate > ghostRate }
    private var isTied: Bool   { abs(userRate - ghostRate) < 0.01 }
    private var gap: Int       { abs(Int((ghostRate - userRate) * 100)) }

    private var topLabel: String    { isAhead ? "You"  : "Dodo" }
    private var bottomLabel: String { isAhead ? "Dodo" : "You"  }
    private var topRate: Double     { isAhead ? userRate  : ghostRate }
    private var bottomRate: Double  { isAhead ? ghostRate : userRate  }
    private var topColor: Color     { isAhead ? .white : Color(hex: "#F97316") }
    private var bottomColor: Color  { isAhead ? Color(hex: "#F97316") : .white }

    private var statusMessage: String {
        if isTied    { return "Dodo noticed. Don't let it happen again." }
        if isAhead   { return "You're ahead of Dodo today. Rare." }
        if gap <= 10 { return "One more task closes the gap." }
        if gap <= 25 { return "Dodo is pulling away. Move." }
        return "Dodo hasn't stopped. Have you?"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // Title
            Text("vs Dodo")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: "#F97316"))

            // Top bar
            RaceBar(label: topLabel, rate: topRate, color: topColor)

            // Bottom bar
            RaceBar(label: bottomLabel, rate: bottomRate, color: bottomColor.opacity(0.45))

            // Gap / status
            HStack(spacing: 6) {
                if isTied {
                    Text("TIED")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "#FFD700"))
                } else {
                    Text(isAhead ? "+\(gap)%" : "-\(gap)%")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(isAhead ? Color(hex: "#34D399") : Color(hex: "#FF4444"))
                }
                Text(statusMessage)
                    .font(.system(size: 12))
                    .foregroundColor(Color(white: 0.5))
            }
        }
        .padding(16)
        .background(Color(white: 0.1))
        .cornerRadius(14)
    }
}

// MARK: - Single Race Bar

struct RaceBar: View {
    let label: String
    let rate: Double
    let color: Color

    @State private var animated: Double = 0

    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text("\(Int(rate * 100))%")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(color == .white ? .white : color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(white: 0.18))
                        .frame(height: 7)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: max(4, geo.size.width * animated), height: 7)
                }
            }
            .frame(height: 7)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                animated = rate
            }
        }
        .onChange(of: rate) { newVal in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                animated = newVal
            }
        }
    }
}

// MARK: - Weekly Score Card (Growth Screen)

struct DodoWeeklyScoreCard: View {
    let userDays: Int
    let dodoDays: Int

    private var userAhead: Bool { userDays > dodoDays }
    private var tied: Bool      { userDays == dodoDays }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This week")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)

            HStack(spacing: 0) {
                // User side
                VStack(spacing: 4) {
                    Text("\(userDays)/7")
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundColor(userAhead ? Color(hex: "#34D399") : .white)
                    Text("You")
                        .font(.system(size: 12))
                        .foregroundColor(Color(white: 0.5))
                }
                .frame(maxWidth: .infinity)

                // Divider
                Text("vs")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(white: 0.3))
                    .frame(width: 32)

                // Dodo side
                VStack(spacing: 4) {
                    Text("\(dodoDays)/7")
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundColor(!userAhead && !tied ? Color(hex: "#F97316") : .white)
                    Text("Dodo")
                        .font(.system(size: 12))
                        .foregroundColor(Color(white: 0.5))
                }
                .frame(maxWidth: .infinity)
            }

            // Week dots
            HStack(spacing: 6) {
                ForEach(0..<7, id: \.self) { i in
                    VStack(spacing: 3) {
                        // User dot
                        Circle()
                            .fill(i < userDays ? Color(hex: "#34D399") : Color(white: 0.2))
                            .frame(width: 8, height: 8)
                        // Dodo dot
                        Circle()
                            .fill(i < dodoDays ? Color(hex: "#F97316") : Color(white: 0.2))
                            .frame(width: 8, height: 8)
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            // Legend
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Circle().fill(Color(hex: "#34D399")).frame(width: 6, height: 6)
                    Text("You").font(.system(size: 11)).foregroundColor(Color(white: 0.4))
                }
                HStack(spacing: 4) {
                    Circle().fill(Color(hex: "#F97316")).frame(width: 6, height: 6)
                    Text("Dodo").font(.system(size: 11)).foregroundColor(Color(white: 0.4))
                }
            }
        }
        .padding(16)
        .background(Color(white: 0.1))
        .cornerRadius(14)
    }
}
