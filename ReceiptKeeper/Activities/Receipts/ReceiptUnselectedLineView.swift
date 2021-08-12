//
//  ReceiptUnselectedLineView.swift
//  ReceiptUnselectedLineView
//
//  Created by Andrei Chenchik on 10/8/21.
//

import SwiftUI

struct ReceiptUnselectedLineView: View {
    @ObservedObject var receiptLine: ReceiptLine
    @ObservedObject var receiptDraft: ReceiptDraft

    @Binding var lineSelectedForPopup: ReceiptLine?

    var body: some View {
        HStack {
            Text(receiptLine.text)
            Spacer()
            Menu {
                Button {
                    receiptDraft.objectWillChange.send()
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
        .frame(height: receiptLine.selected ? 55 : 35)
        .swipeActions(edge: .leading) {
            Button {
                withAnimation {
                    receiptDraft.objectWillChange.send()
                    receiptLine.selected = true
                }
            } label: {
                Image(systemName: "cart.badge.plus")
            }
            .tint(.green)
            
            Button {
                withAnimation {
                    lineSelectedForPopup = receiptLine
                }
            } label: {
                Image(systemName: "square.dashed.inset.filled")
            }
            .tint(.blue)
        }
    }
}

//struct ReceiptUnselectedLineView_Previews: PreviewProvider {
//    static var previews: some View {
//        ReceiptUnselectedLineView()
//    }
//}
