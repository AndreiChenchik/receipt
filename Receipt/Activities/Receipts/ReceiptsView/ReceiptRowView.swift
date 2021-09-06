//
//  ReceiptRowView.swift
//  ReceiptRowView
//
//  Created by Andrei Chenchik on 25/8/21.
//

import SwiftUI
import Combine

struct ReceiptRowView: View {
    let dataController = DataController.shared

    @ObservedObject var receipt: Receipt

    private var cancellables = Set<AnyCancellable>()

    init(receipt: Receipt) {
        _receipt = ObservedObject(wrappedValue: receipt)

        if let store = receipt.store {
            dataController.publisher(for: store, in: dataController.container.viewContext, changeTypes: [.updated])
                .sink(receiveValue: { _ in
                    receipt.objectWillChange.send()
                })
                .store(in: &cancellables)
        }
    }

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
        NavigationLink(destination: ReceiptView(receipt: receipt)) {
            HStack {
                if let storeIcon = receipt.store?.storeIcon {
                    Text(storeIcon)
                        .font(.title2)
                        .frame(width: 30, height: 30)
                } else {
                    Image(systemName: "cart")
                        .font(.title2)
                        .frame(width: 30, height: 30)
                }

                VStack(alignment: .leading) {
                    Text(receipt.storeTitleWithoutIcon)
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
        NavigationLink(destination: ReceiptView(receipt: receipt)) {
            HStack {
                Image(systemName: "doc.text")
                    .font(.title2)
                    .frame(width: 30, height: 30)

                VStack(alignment: .leading) {
                    Text(receipt.storeTitleWithoutIcon)
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
                .frame(width: 30, height: 30)
            
            VStack(alignment: .leading) {
                Text("Processing")
                Text("Draft from \(receiptCreationDate)")
                    .font(.caption)
                    .opacity(0.5)
            }
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
