//
//  StrategyTile.swift
//  AtlasDesk
//
//  Created by Jannic Marcon on 25.09.2025.
//
import SwiftUI
import AtlasCore

struct StrategyTile: View {
    let strategy: LiveStrategyOverview
    /*
     LiveStrategyOverview:
     
     public var id: UUID
     public var name: String
     public var parameters: ParameterSet
     public var pnl: Double
     */

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.blue.opacity(0.15))
                Text(strategy.name)
                    .font(.headline)
                    .padding(.vertical, 26)
            }
            .frame(height: 110)
            
            HStack(spacing: 12) {
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(.background)
                .shadow(radius: 2, y: 1)
        )

    }
    
    private func format(_ value: Double) -> String {
        if value == floor(value) { return String(Int(value)) }
        return String(format: "%.2f", value)
    }


}

#if DEBUG
private extension LiveStrategyOverview {
    static var preview: LiveStrategyOverview {
        // Assuming ParameterSet can be initialized without parameters in preview
        .init(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            name: "Sample Strategy",
            parameters: ParameterSet(parameters: []),
            symbol: "BTC-JANNICMA",
            timeframe: 1,
            pnl: 1234.56
        )
    }
}
#endif

#Preview {
    StrategyTile(strategy: .preview)
        .padding()
        .frame(width: 360)
}
