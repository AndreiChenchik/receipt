//
//  EditReceiptItemView.swift
//  EditReceiptItemView
//
//  Created by Andrei Chenchik on 29/8/21.
//

import SwiftUI

struct EditReceiptItemView: View {
    @ObservedObject var item: Item

    @State private var title: String
    @State private var priceString: String

    @EnvironmentObject var dataController: DataController

    init(item: Item) {
        self.item = item
        self.title = item.itemTitle
        self.priceString = item.itemPriceString
    }

    func update() {
        item.title = title

        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true

        if let price = formatter.number(from: priceString) as? NSDecimalNumber {
            item.price = price
        } else {
            priceString = item.itemPriceString
        }

        dataController.saveIfNeeded()
    }

    var body: some View {
        HStack(alignment:.top) {
            Image(systemName: "cart")
                .foregroundColor(.accentColor)
                .padding(.top, 11)
                .frame(width: 30)

            TextEditor(text: $title.onChange(update))
                .offset(x: -5)
                .onAppear {
                    let text = title
                    title = ""
                    title = text
                }

            VStack(alignment: .leading, spacing: 0) {
                Text("Price")
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack(spacing: 0) {
                    TextField("Item price", text: $priceString.onChange(update), prompt: Text("0,00"))
                        .keyboardType(.decimalPad)
                    Text("€")
                }
            }
            .padding(.top, 7)
            .padding(.bottom, 5)
            .frame(width: 55)
        }
    }
}

//struct EditReceiptItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditReceiptItemView_swift()
//    }
//}
