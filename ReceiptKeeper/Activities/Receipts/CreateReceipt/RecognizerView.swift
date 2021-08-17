//
//  RecognizerView.swift
//  RecognizerView
//
//  Created by Andrei Chenchik on 8/8/21.
//

import SwiftUI

struct RecognizerView: View {
    @EnvironmentObject var dataController: DataController
    
    @ObservedObject var receiptDraft: Draft
    
    var body: some View {
        InnerView(receiptDraft: receiptDraft, dataController: dataController)
    }
    
    
    struct InnerView: View {
        @StateObject var viewModel: ViewModel
        
        @ObservedObject var receiptDraft: Draft
        
        @State var lineSelectedForPopup: DraftLine? = nil
        
        init(receiptDraft: Draft, dataController: DataController) {
            let viewModel = ViewModel(receiptDraft: receiptDraft, dataController: dataController)
            _viewModel = StateObject(wrappedValue: viewModel)
            _receiptDraft = ObservedObject(wrappedValue: receiptDraft)
        }
        
        var body: some View {
            if !receiptDraft.draftLines.isEmpty {
                Form {
                    Section(header: Text("Title")) {
                        TextField("Store title", text: $receiptDraft.storeTitle)
                        TextField("Store location", text: $receiptDraft.storeAddress)
                    }
                    
                    Section(header: Text("Date")) {
                        DatePicker("Receipt date", selection: $receiptDraft.transactionDate.value, in: ...Date())
                    }
                    
                    Section(header: Text("Items")) {
                        ForEach(receiptDraft.selectedReceiptLines) { line in
                            SelectedDraftLineView(receiptLine: line, receiptDraft: receiptDraft, lineSelectedForPopup: $lineSelectedForPopup)
                        }
                    }
                    
                    Section(header: Text("Total")) {
                        TextField("Total value", text: $receiptDraft.totalValue)
                    }
                    
                    if let scanImage = receiptDraft.scanImage {
                        Section {
                            NavigationLink {
                                ZStack {
                                    Image(uiImage: scanImage)
                                        .resizable()
                                        .scaledToFit()
                                    
                                    if let charBoxesLayer = receiptDraft.scanCharBoxesLayer {
                                        Image(uiImage: charBoxesLayer)
                                            .resizable()
                                            .scaledToFit()
                                    }
                                    
                                    if let textBoxesLayer = receiptDraft.scanTextBoxesLayer {
                                        Image(uiImage: textBoxesLayer)
                                            .resizable()
                                            .scaledToFit()
                                    }
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding(.vertical, 15)
                            } label: {
                                Text("Recognized Image")
                            }
                        }
                    }
                    
                    Section(header: Text("Other lines")) {
                        ForEach(receiptDraft.unselectedReceiptLines) { line in
                            UnselectedDraftLineView(receiptLine: line, receiptDraft: receiptDraft, lineSelectedForPopup: $lineSelectedForPopup)
                        }
                    }
                }
                .popover(item: $lineSelectedForPopup) { line in
                    Image(uiImage: receiptDraft.scanImage!.cropped(to: line.boundingBox))
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
                        Task.init(priority: .userInitiated) {
                            await viewModel.recognize()
                        }
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
