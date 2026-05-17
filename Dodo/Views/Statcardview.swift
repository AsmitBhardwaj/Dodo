import SwiftUI

// MARK: - Stats Section (drop into GrowthView or TodayView)

struct YourStatsSection: View {
    @ObservedObject var stats: StatsManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your stats")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)

            ForEach(StatType.allCases, id: \.self) { type in
                StatCardView(stats: stats, type: type)
            }
        }
        .padding(20)
        .background(Color(white: 0.08))
        .cornerRadius(20)
    }
}

// MARK: - Individual Stat Card

struct StatCardView: View {
    @ObservedObject var stats: StatsManager
    let type: StatType

    @State private var animatedValue: Double   = 0
    @State private var animatedCeiling: Double = 1

    private var stat: DodoStat { stats.stat(for: type) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // Header row
            HStack {
                Image(systemName: type.icon)
                    .foregroundColor(type.color)
                    .font(.system(size: 16, weight: .bold))

                Text(type.displayName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                // Percentage — turns red when critical
                Text("\(Int(stat.value * 100))%")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(percentColor)
            }

            // Three-zone bar
            ThreeZoneBar(
                value:   animatedValue,
                ceiling: animatedCeiling,
                color:   type.color
            )

            // Dynamic subtitle
            Text(stats.subtitle(for: type))
                .font(.system(size: 12))
                .foregroundColor(Color(white: 0.55))
                .lineLimit(2)
        }
        .padding(16)
        .background(cardBackground)
        .cornerRadius(14)
        .onAppear { animateTo(stat) }
        .onChange(of: stat.value)   { _ in animateTo(stat) }
        .onChange(of: stat.ceiling) { _ in animateTo(stat) }
    }

    // MARK: - Helpers

    private var percentColor: Color {
        if stat.value <= 0     { return .red }
        if stat.value < 0.25   { return Color(hex: "#FF4444") }
        if stat.value < 0.5    { return Color(hex: "#FF8C00") }
        return type.color
    }

    private var cardBackground: Color {
        if stat.value <= 0   { return Color(hex: "#1A0A0A") }   // danger tint
        if stat.value < 0.25 { return Color(hex: "#1A1008") }   // warning tint
        return Color(white: 0.12)
    }

    private func animateTo(_ s: DodoStat) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            animatedValue   = s.value
            animatedCeiling = s.ceiling
        }
    }
}

// MARK: - Three Zone Bar

struct ThreeZoneBar: View {
    let value: Double      // 0–1 current fill
    let ceiling: Double    // 0–1 max recoverable
    let color: Color

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width

            ZStack(alignment: .leading) {
                // Zone 3: fully dark — ceiling damage (unrecoverable until rebuilt)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(white: 0.15))
                    .frame(width: w, height: 8)

                // Zone 2: faded color — recoverable gap (between value and ceiling)
                if ceiling > value {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.2))
                        .frame(width: max(0, w * ceiling), height: 8)
                }

                // Zone 1: solid color — current value
                if value > 0 {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            value < 0.25
                            ? Color(hex: "#FF4444")   // go red when critical
                            : color
                        )
                        .frame(width: max(4, w * value), height: 8)
                }

                // Ceiling marker line
                if ceiling < 0.98 {
                    Rectangle()
                        .fill(Color(white: 0.6))
                        .frame(width: 2, height: 12)
                        .offset(x: w * ceiling - 1, y: -2)
                }
            }
        }
        .frame(height: 8)
    }
}

// MARK: - Preview

struct YourStatsSection_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            YourStatsSection(stats: StatsManager())
                .padding()
        }
    }
}
