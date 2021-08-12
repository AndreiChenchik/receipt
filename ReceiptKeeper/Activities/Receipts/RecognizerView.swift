//
//  RecognizerView.swift
//  RecognizerView
//
//  Created by Andrei Chenchik on 8/8/21.
//

import SwiftUI

struct RecognizerView: View {
    @EnvironmentObject var dataController: DataController

    @ObservedObject var receiptDraft: ReceiptDraft

    var body: some View {
        RecognizerViewChild(receiptDraft: receiptDraft, dataController: dataController)
    }
}

struct RecognizerViewChild: View {
    @StateObject var viewModel: ViewModel

    @ObservedObject var receiptDraft: ReceiptDraft

    init(receiptDraft: ReceiptDraft, dataController: DataController) {
        let viewModel = ViewModel(receiptDraft: receiptDraft, dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
        _receiptDraft = ObservedObject(wrappedValue: receiptDraft)
    }

    var body: some View {
        if !receiptDraft.receiptLines.isEmpty {
            Form {
                Section(header: Text("Title")) {
                    TextField("Store title", text: $receiptDraft.storeTitle)
                    TextField("Store location", text: $receiptDraft.storeAddress)
                }

                Section(header: Text("Date")) {
                    TextField("Date", text: $receiptDraft.transactionDate)
                }

                Section(header: Text("Items")) {
                    ForEach($receiptDraft.selectedReceiptLines) { $line in
                        ReceiptLineView(receiptLine: line, receiptDraft: receiptDraft)
                    }
                    .onDelete { indexSet in
                        withAnimation {
                            for index in indexSet {
                                receiptDraft.objectWillChange.send()
                                receiptDraft.selectedReceiptLines[index].selected = false
                            }
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
                    ForEach(receiptDraft.unselectedReceiptLines) { line in
                        ReceiptLineView(receiptLine: line, receiptDraft: receiptDraft)
                    }
                }
            }
            .onAppear(perform: {
                print(viewModel.isRecognitionDone)
            })
            .navigationTitle("New receipt")
            .navigationBarTitleDisplayMode(.inline)
        } else {
            ProgressView()
                .onAppear {
                    print(viewModel.isRecognitionDone)
                    viewModel.recognizeDraft()
                    print(viewModel.isRecognitionDone)
                }
        }
    }
}

//struct RecognizerView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecognizerView()
//    }
//}
