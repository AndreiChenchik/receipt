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
        InnerView(receiptDraft: receiptDraft, dataController: dataController)
    }


    struct InnerView: View {
        @StateObject var viewModel: ViewModel

        @ObservedObject var receiptDraft: ReceiptDraft

        @State var lineSelectedForPopup: ReceiptLine? = nil

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
                        ForEach(receiptDraft.selectedReceiptLines) { line in
                            ReceiptSelectedLineView(receiptLine: line, receiptDraft: receiptDraft, lineSelectedForPopup: $lineSelectedForPopup)
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
                            ReceiptUnselectedLineView(receiptLine: line, receiptDraft: receiptDraft, lineSelectedForPopup: $lineSelectedForPopup)
                        }
                    }
                }
                .popover(item: $lineSelectedForPopup) { line in
                    Image(uiImage: receiptDraft.scanImage.croppedToRect(line.boundingBox))
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(40)
                        .ignoresSafeArea()
                        .background(Color.secondary)
                }
                .navigationTitle("New receipt")
                .navigationBarTitleDisplayMode(.inline)
            } else {
                ProgressView()
                    .onAppear {
                        viewModel.recognizeDraft()
                    }
            }
        }
    }
}
//struct RecognizerView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecognizerView()
//    }
//}
