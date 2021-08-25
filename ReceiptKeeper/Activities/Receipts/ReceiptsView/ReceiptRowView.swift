//
//  ReceiptRowView.swift
//  ReceiptRowView
//
//  Created by Andrei Chenchik on 25/8/21.
//

import SwiftUI

struct ReceiptRowView: View {
    @ObservedObject var receipt: Receipt

    var normalReceipt: some View {
        NavigationLink(destination: EditReceiptView(receipt: receipt)) {
            VStack(alignment: .leading) {
                Text(receipt.receiptCreationDate, style: .date)
                Text(receipt.receiptCreationDate, style: .time)
                    .font(.caption)
                    .opacity(0.5)
            }
        }
    }

    var draftReceipt: some View {
        NavigationLink(destination: EditReceiptView(receipt: receipt)) {
            HStack {
                Image(systemName: "doc.text")
                    .frame(width: 20, height: 20)

                VStack(alignment: .leading) {
                    Text("Unknown")
                    Text("Draft from 2012.12.12 14:20")
                        .font(.caption)
                        .opacity(0.5)
                }
                .padding(.horizontal, 5)
            }
        }
    }

    var processingReceipt: some View {
        HStack {
            ProgressView()
                .frame(width: 20, height: 20)
            VStack(alignment: .leading) {
                Text("Processing")
                Text("Draft from 2012.12.12 14:20")
                    .font(.caption)
                    .opacity(0.5)
            }
            .padding(.horizontal, 5)
        }
    }

    var body: some View {
        Group {
            switch receipt.state {
            case .processing:
                processingReceipt
            case .draft:
                draftReceipt
            default:
                normalReceipt
            }
        }
    }
}

//struct ReceiptRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        ReceiptRowView()
//    }
//}
