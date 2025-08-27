//
//  CsvImportViewModel.swift
//  AtlasDesk
//
//  Created by Jannic Marcon on 27.08.2025.
//
import SwiftUI
import AtlasSim

final class CsvImportViewModel: ObservableObject {
    @Published var assetName: String = ""
    @Published var selectedCSVURLs: [URL] = []
    @Published var showingFileImporter: Bool = false
    
    func confirmSelection() {
        let klineImporter = KlineImporter()
        
        if selectedCSVURLs.count > 0 {
            Task{
                do{
                    let accessibleURLs = selectedCSVURLs.filter { $0.startAccessingSecurityScopedResource() }
                    defer { accessibleURLs.forEach { $0.stopAccessingSecurityScopedResource() } }

                    let candles = try klineImporter.mergeAndFixCsv(urls: accessibleURLs)
                    //TODO: give info to user for yes/no
                    let importSucceeded = await klineImporter.importChart(symbol: assetName, timeframe: 1, candles: candles)
                } catch {
                    print("error in confirmSelection(): \(error)")
                }
            }
        }
    }
}
