//
//  ReceiptRowView.swift
//  ReceiptRowView
//
//  Created by Andrei Chenchik on 25/8/21.
//

import SwiftUI

struct ReceiptRowView: View {
    @ObservedObject var receipt: Receipt

    var receiptPurchaseDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        return formatter.string(from: receipt.receiptPurchaseDate)
    }

    var receiptCreationDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        return formatter.string(from: receipt.receiptCreationDate)
    }

    var normalReceipt: some View {
        NavigationLink(destination: EditReceiptView(receipt: receipt)) {
            HStack {
                if let vendorIcon = receipt.vendor?.vendorIcon {
                    Text(vendorIcon)
                        .font(.title2)
                        .frame(width: 30)
                } else {
                    Image(systemName: "cart")
                        .frame(width: 30)
                }

                VStack(alignment: .leading) {
                    Text(receipt.vendorTitleWithoutIcon)
                    Text(receiptPurchaseDate)
                        .font(.caption)
                        .opacity(0.5)
                }

                Spacer()

                Text(receipt.receiptTotal)
                Text("€")
            }
        }
    }

    var draftReceipt: some View {
        NavigationLink(destination: EditReceiptView(receipt: receipt)) {
            HStack {
                Image(systemName: "doc.text")
                    .frame(width: 30)

                VStack(alignment: .leading) {
                    Text(receipt.vendorTitleWithoutIcon)
                    Text(receiptPurchaseDate)
                        .font(.caption)
                        .opacity(0.5)
                }

                Spacer()

                Text(receipt.receiptTotal)
                Text("€")
            }
        }
    }

    var processingReceipt: some View {
        HStack {
            ProgressView()
                .frame(width: 20, height: 20)
            VStack(alignment: .leading) {
                Text("Processing")
                Text("Draft from \(receiptCreationDate)")
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

struct ReceiptRowView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            ReceiptRowView(receipt: Receipt.example)
        }
    }
}
