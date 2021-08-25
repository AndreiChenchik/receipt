//
//  RecognizedContentView.swift
//  RecognizedContentView
//
//  Created by Andrei Chenchik on 25/8/21.
//

import SwiftUI

struct RecognizedContentView: View {
    @ObservedObject var receipt: Receipt

    @State private var isShowingScanImageView = false

    var viewScanButton: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            if receipt.scanImageData != nil {
                //TODO: Add photo picker for devices without scan
                Button(action: {
                    isShowingScanImageView = true
                }) {
                    Label("View scan", systemImage: "doc.text.viewfinder")
                }
            }
        }
    }

    func lineIcon(for line: RecognizedContent.Line) -> String {
        switch line.lineType {
        case .total:
            return "sum"
        case .item:
            return "cart"
        default:
            return "questionmark"
        }
    }

    var body: some View {
        if let lines = receipt.recognitionData?.content.lines {
            List {
                ForEach(lines) { line in
                    Label("\(line.label) '\(line.value ?? 0)", systemImage: lineIcon(for: line))
                }
            }
            .sheet(isPresented: $isShowingScanImageView) {
                ScanImageView(receipt: receipt)
            }
            .navigationTitle("Recognized content")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                viewScanButton
            }
        }
    }
}

//struct RecognizedContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecognizedContentView()
//    }
//}
