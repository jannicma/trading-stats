//
//  Sparkline.swift
//  AtlasDesk
//
//  Created by Jannic Marcon on 25.09.2025.
//
import SwiftUI

struct Sparkline: View {
    @State private var values: [CGFloat] = (0..<24).map { _ in .random(in: 0.2...1.0) }

    var body: some View {
        GeometryReader { geo in
            let step = geo.size.width / CGFloat(max(values.count - 1, 1))
            Path { path in
                for i in values.indices {
                    let x = CGFloat(i) * step
                    let y = (1 - values[i]) * geo.size.height
                    if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                    else { path.addLine(to: CGPoint(x: x, y: y)) }
                }
            }
            .stroke(.secondary.opacity(0.6), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
