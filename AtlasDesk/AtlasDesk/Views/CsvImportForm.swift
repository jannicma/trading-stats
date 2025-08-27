//
//  CsvImportForm.swift
//  AtlasDesk
//
//  Created by Jannic Marcon on 27.08.2025.
//
import SwiftUI

struct CsvImportForm: View {
    @ObservedObject var viewModel: CsvImportViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Import Data")
                .font(.title2)

            // Asset name input
            TextField("Asset", text: $viewModel.assetName)
                .textFieldStyle(.roundedBorder)

            // File selection box
            VStack(alignment: .leading, spacing: 8) {
                Text("CSV files")
                    .font(.headline)
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.secondary)
                        .frame(minHeight: 120)
                    VStack(spacing: 12) {
                        if viewModel.selectedCSVURLs.isEmpty {
                            Text("No files selected")
                                .foregroundStyle(.secondary)
                        } else {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 6) {
                                    ForEach(viewModel.selectedCSVURLs, id: \.self) { url in
                                        Text(url.lastPathComponent)
                                            .lineLimit(1)
                                    }
                                }
                                .padding(8)
                            }
                        }
                        Button("choose CSV files") {
                            viewModel.showingFileImporter = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }

            HStack {
                Spacer()
                Button("Abbrechen") { dismiss() }
                Button("OK") {
                    viewModel.confirmSelection()
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(minWidth: 480, minHeight: 360)
        .fileImporter(
            isPresented: $viewModel.showingFileImporter,
            allowedContentTypes: [.commaSeparatedText],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                viewModel.selectedCSVURLs = urls
            case .failure:
                viewModel.selectedCSVURLs = []
            }
        }
    }
}
