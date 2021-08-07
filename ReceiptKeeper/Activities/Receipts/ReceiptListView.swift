//
//  ReceiptListView.swift
//  ReceiptListView
//
//  Created by Andrei Chenchik on 7/8/21.
//

import SwiftUI

struct ReceiptListView: View {
    @EnvironmentObject var dataController: DataController

    var body: some View {
        List {
            if !dataController.drafts.isEmpty {
                Section(header: Text("Drafts")) {
                    ForEach(dataController.drafts) { draft in
                        Text(draft.id.uuidString)
                    }
                }
            }

            if !dataController.receipts.isEmpty {
                Section {
                    ForEach(dataController.receipts) { receipt in
                        Text(receipt.id.uuidString)
                    }
                }
            }
        }
    }
}

struct ReceiptListView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptListView()
    }
}
