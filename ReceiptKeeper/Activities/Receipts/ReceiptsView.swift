//
//  ReceiptsView.swift
//  ReceiptsView
//
//  Created by Andrei Chenchik on 5/8/21.
//

import SwiftUI

struct ReceiptsView: View {
    static let tag: String? = "Receipts"

    @StateObject var viewModel: ViewModel

    @State private var isShowingAddReceiptsView = false

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var scanNewReceiptsButton: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            if viewModel.isCapableToScan {
                Button(action: {
                    isShowingAddReceiptsView = true
                }) {
                    Label("Add receipt", systemImage: "doc.badge.plus")
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            Group {
                if viewModel.haveReceiptsToShow {
                    ReceiptListView()
                } else {
                    EmptyReceiptListView()
                }
            }
            .toolbar {
                scanNewReceiptsButton
            }
            .navigationTitle("Receipts")
            .sheet(isPresented: $isShowingAddReceiptsView) {
                ReceiptScannerView()
                    .ignoresSafeArea()
            }
        }
    }
}

struct ReceiptsView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptsView(dataController: DataController())
    }
}
