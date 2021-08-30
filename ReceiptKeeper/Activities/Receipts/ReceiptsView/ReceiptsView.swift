//
//  ReceiptsView.swift
//  ReceiptsView
//
//  Created by Andrei Chenchik on 5/8/21.
//

import SwiftUI

struct ReceiptsView: View {
    static let tag: String? = "Receipts"
    
    @EnvironmentObject var dataController: DataController
    var body: some View {
        InnerView(dataController: dataController)
    }
}

extension ReceiptsView {
    struct InnerView: View {
        @StateObject var viewModel: ViewModel
        
        @State private var isShowingScannerView = false

        init(dataController: DataController) {
            let viewModel = ViewModel(dataController: dataController)
            _viewModel = StateObject(wrappedValue: viewModel)
        }
        
        var newReceiptButton: some ToolbarContent {
            ToolbarItem(placement: .primaryAction) {
                if viewModel.isCapableToScan {
                    //TODO: Add photo picker for devices without scan
                    Button(action: {
                        isShowingScannerView = true
                    }) {
                        Label("Add receipt", systemImage: "doc.badge.plus")
                    }
                }
            }
        }

        var receiptsList: some View {
            List {
                receiptsListSection(from: viewModel.draftReceipts,
                                    header: "Review Drafts (\(viewModel.draftReceipts.count))")

                receiptsListSection(from: viewModel.readyReceipts,
                                    header: "Purchases")
            }
        }

        func receiptsListSection(from receipts: [Receipt], header: String) -> some View {
            Group {
                if !receipts.isEmpty {
                    Section(header: Text(header)) {
                        ForEach(receipts, content: ReceiptRowView.init)
                            .onDelete { $0.forEach { viewModel.delete(receipts[$0]) } }
                    }
                }
            }
        }
        
        var body: some View {
            NavigationView {
                Group {
                    if viewModel.allReceipts.isEmpty {
                        Text("No receipts to display, start by scanning a new one!")
                            .foregroundColor(.secondary)
                            .padding(15)
                    } else {
                        receiptsList
                    }
                }
                .toolbar {
                    newReceiptButton
                }
                .navigationTitle("Receipts")
                .sheet(isPresented: $isShowingScannerView, onDismiss: viewModel.processNewScans) {
                    ScannerView(newScanImages: $viewModel.newScanImages)
                        .ignoresSafeArea()
                }

                SelectSomethingView()
            }
        }
    }
}

struct ReceiptsView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        ReceiptsView()
            .environmentObject(dataController)
    }
}
