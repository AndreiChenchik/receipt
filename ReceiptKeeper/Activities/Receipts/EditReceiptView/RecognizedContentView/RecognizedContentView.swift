//
//  RecognizedContentView.swift
//  RecognizedContentView
//
//  Created by Andrei Chenchik on 25/8/21.
//

import SwiftUI

struct RecognizedContentView: View {
    @ObservedObject var receipt: Receipt
    @EnvironmentObject var dataController: DataController

    @State private var isShowingScanImageView = false
    @State private var selectedLine: RecognizedContent.Line? = nil

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

    func saveChanges() {
        dataController.updateReceipt(withID: receipt.objectID, from: receipt.recognitionData?.content)
    }

    var body: some View {
        if let lines = receipt.recognitionData?.content.lines {
            List {
                ForEach(lines) { line in
                    RecognizedContentLineView(receipt: receipt, line: line)
                }
            }
            .onDisappear(perform: saveChanges)
            .sheet(isPresented: $isShowingScanImageView) {
                ScanImageView(receipt: receipt)
            }
            .navigationTitle("Recognized content")
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
