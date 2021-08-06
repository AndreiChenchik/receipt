//
//  ReceiptsView.swift
//  ReceiptsView
//
//  Created by Andrei Chenchik on 5/8/21.
//

import SwiftUI

struct ReceiptsView: View {
    static let tag: String? = "Receipts"

    @State private var isShowingAddReceiptsView = false

    var addReceiptButton: some View {
        Button(action: {
            isShowingAddReceiptsView = true
        }) {
            Label("Add receipt", systemImage: "doc.badge.plus")
        }
    }

    var body: some View {
        NavigationView {
            Text("Nothing to see here")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        addReceiptButton
                    }
                }
                .navigationTitle("Receipts")
                .fullScreenCover(isPresented: $isShowingAddReceiptsView, content: AddReceiptsView.init)
        }
    }
}

struct ReceiptsView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptsView()
    }
}
