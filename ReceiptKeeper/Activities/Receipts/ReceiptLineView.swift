//
//  ReceiptLineView.swift
//  ReceiptLineView
//
//  Created by Andrei Chenchik on 10/8/21.
//

import SwiftUI

struct ReceiptLineView: View {
    @ObservedObject var receiptLine: ReceiptLine
    let receiptDraft: ReceiptDraft

    var body: some View {
        if receiptLine.selected {
            VStack {
                TextField("Label", text: $receiptLine.label)

                TextField("Value", text: $receiptLine.value)
                    .multilineTextAlignment(.trailing)
            }
        } else {
            HStack {
                Text(receiptLine.text)
                Spacer()
                Menu {
                    Button {
                        receiptLine.selected = true
                    } label: {
                        Label("Add to purchased items", systemImage: "cart.badge.plus")
                    }

                    Button {
                        receiptDraft.totalValue = receiptLine.value
                    } label: {
                        Label("Use as total", systemImage: "dollarsign.circle")
                    }

                    Button {
                        receiptDraft.transactionDate = receiptLine.label
                    } label: {
                        Label("Extract purchase date", systemImage: "calendar")
                    }

                    Button {
                        receiptDraft.storeTitle = receiptLine.label
                    } label: {
                        Label("Use as store title", systemImage: "textformat.abc")
                    }

                    Button {
                        receiptDraft.storeAddress += " " + receiptLine.label
                        receiptDraft.storeAddress = receiptDraft.storeAddress.trimmingCharacters(in: .whitespacesAndNewlines)
                    } label: {
                        Label("Add to store address", systemImage: "mappin.and.ellipse")
                    }
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.primary)
                }
            }
        }
    }
}

//struct ReceiptLineView_Previews: PreviewProvider {
//    static var previews: some View {
//        ReceiptLineView()
//    }
//}