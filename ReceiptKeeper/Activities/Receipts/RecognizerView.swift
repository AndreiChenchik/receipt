//
//  RecognizerView.swift
//  RecognizerView
//
//  Created by Andrei Chenchik on 8/8/21.
//

import SwiftUI

struct RecognizerView: View {
    @StateObject var viewModel: ViewModel
    @StateObject var receiptDraft: ReceiptDraft

    init(receiptDraft: ReceiptDraft, dataController: DataController) {
        let viewModel = ViewModel(receiptDraft: receiptDraft, dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
        _receiptDraft = StateObject(wrappedValue: receiptDraft)
    }

    var body: some View {
        if viewModel.isRecognitionDone {
            Form {
                Section(header: Text("Title")) {
                    TextField("Store title", text: $receiptDraft.storeTitle)
                    TextField("Store location", text: $receiptDraft.storeAddress)
                }

                Section(header: Text("Date")) {
                    TextField("Date", text: $receiptDraft.transactionDate)
                }

                Section(header: Text("Items")) {
                    ForEach(receiptDraft.receiptLines.filter { $0.selected }) { line in
                        ReceiptLineView(receiptLine: line, receiptDraft: receiptDraft)
                            .swipeActions(edge: .trailing) {
                                Button {
                                    let thisLine = receiptDraft.receiptLines.first { $0 == line }
                                    thisLine?.selected = false
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                                .tint(.red)
                            }
                    }
                }

                Section(header: Text("Total")) {
                    TextField("Total value", text: $receiptDraft.totalValue)
                }

                Section {
                    NavigationLink {
                        ZStack {
                            Image(uiImage: receiptDraft.scanImage)
                                .resizable()
                                .scaledToFit()
                            Image(uiImage: receiptDraft.scanCharBoxesLayer)
                                .resizable()
                                .scaledToFit()
                            Image(uiImage: receiptDraft.scanTextBoxesLayer)
                                .resizable()
                                .scaledToFit()
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.vertical, 15)
                    } label: {
                        Text("Recognized Image")
                    }
                }

                Section(header: Text("Other lines")) {
                    ForEach(receiptDraft.receiptLines.filter { !$0.selected }) { line in
                        ReceiptLineView(receiptLine: line, receiptDraft: receiptDraft)
                            .swipeActions(edge: .leading) {
                                Button {
                                    let thisLine = receiptDraft.receiptLines.first { $0 == line }
                                    thisLine?.selected = false
                                } label: {
                                    Label("Add to purchased items", systemImage: "cart.badge.plus")
                                }
                                .tint(.green)
                            }
                    }
                }
            }
            .navigationTitle("New receipt")
            .navigationBarTitleDisplayMode(.inline)
        } else {
            ProgressView()
                .onAppear(perform: viewModel.recognizeDraft)
        }
    }
}

//struct RecognizerView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecognizerView()
//    }
//}
