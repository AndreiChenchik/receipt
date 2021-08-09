//
//  ReceiptsListView.swift
//  ReceiptsListView
//
//  Created by Andrei Chenchik on 7/8/21.
//

import SwiftUI

struct ReceiptsListView: View {
    @EnvironmentObject var dataController: DataController

    var body: some View {
        List {
            if !dataController.drafts.isEmpty {
                Section(header: Text("Drafts")) {
                    ForEach(dataController.drafts) { receiptDraft in
                        NavigationLink {
                            RecognizerView(receiptDraft: receiptDraft, dataController: dataController)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(receiptDraft.dateCreated, style: .date)
                                Text(receiptDraft.dateCreated, style: .time)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
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
        ReceiptsListView()
    }
}
