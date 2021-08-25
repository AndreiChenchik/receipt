//
//  SelectedDraftLineView.swift
//  SelectedDraftLineView
//
//  Created by Andrei Chenchik on 10/8/21.
//

import SwiftUI

struct SelectedDraftLineView: View {
    @ObservedObject var receiptLine: DraftLine
    @ObservedObject var receiptDraft: Draft

    @Binding var lineSelectedForPopup: DraftLine?

    var body: some View {
        HStack {
            VStack{
                TextField("Label", text: $receiptLine.label)

                TextField("Value", text: $receiptLine.value)
                    .multilineTextAlignment(.trailing)
            }
        }
        .frame(height: receiptLine.selected ? 55 : 35)
        .swipeActions {
            Button(role: .destructive) {
                withAnimation {
                    receiptDraft.objectWillChange.send()
                    receiptLine.selected = false
                }
            } label: {
                Image(systemName: "cart.badge.minus")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
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

//struct ReceiptLineView_Previews: PreviewProvider {
//    static var previews: some View {
//        SelectedDraftLineView()
//    }
//}
