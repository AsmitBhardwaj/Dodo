//
//  RadarView.swift
//  Dodo
//
//  Created by Asmit Bhardwaj on 17/05/26.
//


import SwiftUI

struct RadarView: View {
    let scores: RadarScores

    private let axes: [(label: String, keyPath: KeyPath<RadarScores, Double>)] = [
        ("Focus",       \.focus),
        ("Output",      \.output),
        ("Recovery",    \.recovery),
        ("Consistency", \.consistency)
    ]

    var body: some View {
        Canvas { context, size in
            let cx = size.width / 2
            let cy = size.height / 2
            let r = min(cx, cy) * 0.72

            // Grid rings
            for i in 1...4 {
                let fraction = Double(i) / 4.0
                var ring = Path()
                for (j, axis) in axes.enumerated() {
                    let angle = angleFor(index: j)
                    let pt = CGPoint(
                        x: cx + r * fraction * cos(angle),
                        y: cy + r * fraction * sin(angle)
                    )
                    if j == 0 { ring.move(to: pt) }
                    else { ring.addLine(to: pt) }
                }
                ring.closeSubpath()
                context.stroke(ring, with: .color(.white.opacity(0.08)), lineWidth: 1)
            }

            // Axis lines
            for (j, _) in axes.enumerated() {
                let angle = angleFor(index: j)
                var line = Path()
                line.move(to: CGPoint(x: cx, y: cy))
                line.addLine(to: CGPoint(x: cx + r * cos(angle), y: cy + r * sin(angle)))
                context.stroke(line, with: .color(.white.opacity(0.1)), lineWidth: 1)
            }

            // Score polygon
            var poly = Path()
            for (j, axis) in axes.enumerated() {
                let value = scores[keyPath: axis.keyPath] / 100.0
                let angle = angleFor(index: j)
                let pt = CGPoint(
                    x: cx + r * value * cos(angle),
                    y: cy + r * value * sin(angle)
                )
                if j == 0 { poly.move(to: pt) }
                else { poly.addLine(to: pt) }
            }
            poly.closeSubpath()
            context.fill(poly, with: .color(Color.dodoOrange.opacity(0.2)))
            context.stroke(poly, with: .color(.dodoOrange), lineWidth: 2)

            // Dots
            for (j, axis) in axes.enumerated() {
                let value = scores[keyPath: axis.keyPath] / 100.0
                let angle = angleFor(index: j)
                let pt = CGPoint(
                    x: cx + r * value * cos(angle),
                    y: cy + r * value * sin(angle)
                )
                var dot = Path()
                dot.addEllipse(in: CGRect(x: pt.x - 4, y: pt.y - 4, width: 8, height: 8))
                context.fill(dot, with: .color(.dodoOrange))
            }

            // Labels
            for (j, axis) in axes.enumerated() {
                let angle = angleFor(index: j)
                let labelR = r + 20
                let pt = CGPoint(x: cx + labelR * cos(angle), y: cy + labelR * sin(angle))
                context.draw(
                    Text(axis.label)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.45)),
                    at: pt
                )
            }
        }
    }

    private func angleFor(index: Int) -> Double {
        let step = (2 * Double.pi) / Double(axes.count)
        return -Double.pi / 2 + Double(index) * step
    }
}