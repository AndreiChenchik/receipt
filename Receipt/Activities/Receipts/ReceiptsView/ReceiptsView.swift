//
//  ReceiptsView.swift
//  ReceiptsView
//
//  Created by Andrei Chenchik on 5/8/21.
//

import SwiftUI

struct ReceiptsView: View {
    static let tag: String? = "Receipts"
    
    @StateObject var viewModel = ViewModel()
    
    @State private var showingScannerView = false
    @State private var showingPickerView = false
    
    var newReceiptMenu: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu {
                if viewModel.isCapableToScan {
                    //TODO: Add photo picker for devices without scan
                    Button(action: {
                        showingScannerView = true
                    }) {
                        Label("Scan receipt", systemImage: "doc.text.viewfinder")
                    }
                }
                
                Button {
                    showingPickerView = true
                } label: {
                    Label("Add from library", systemImage: "photo.on.rectangle.angled")
                }
                
                Button {
                    viewModel.createReceipt()
                } label: {
                    Label("Create empty receipt", systemImage: "doc")
                }
            } label: {
                Label("Add", systemImage: "plus.app")
            }
        }
    }
    
    var receiptsList: some View {
        List {
            receiptsListSection(from: viewModel.draftReceipts,
                                header: "Drafts for review (\(viewModel.draftReceipts.count))")
            
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
            .sheet(isPresented: $showingPickerView, onDismiss: viewModel.processNewScans) {
                ImagePickerView(newImages: $viewModel.newScanImages)
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $showingScannerView, onDismiss: viewModel.processNewScans) {
                ScannerView(newScanImages: $viewModel.newScanImages)
                    .ignoresSafeArea()
            }
            .toolbar {
                newReceiptMenu
            }
            .navigationTitle("Receipts")
            
            
            SelectSomethingView()
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
