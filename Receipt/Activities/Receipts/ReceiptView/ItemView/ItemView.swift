//
//  ItemView.swift
//  ItemView
//
//  Created by Andrei Chenchik on 29/8/21.
//

import SwiftUI
import Combine

struct ItemView: View {
    let dataController = DataController.shared

    @ObservedObject var item: Item

    @State private var title: String
    @State private var priceString: String
    @State private var quantityString: String

    private var cancellables = Set<AnyCancellable>()

    init(item: Item) {
        self.item = item
        self.title = item.wrappedTitle
        self.priceString = item.itemPriceString
        self.quantityString = item.quantityString

        if let type = item.type {
            dataController.publisher(for: type, in: dataController.container.viewContext, changeTypes: [.updated])
                .sink(receiveValue: { _ in
                    item.objectWillChange.send()
                })
                .store(in: &cancellables)
        }
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

        if !quantityString.isEmpty,
           let quantity = formatter.number(from: quantityString) as? NSDecimalNumber {
            item.quantity = quantity
        } else {
            quantityString = item.quantityString
        }
    }

    var body: some View {
        HStack(alignment: .top) {
            GoodsTypePicker(item: item)

            ZStack(alignment: .topLeading) {
                Text(title)
                    .opacity(0)

                TextEditor(text: $title.onChange(update))
                    .padding(.vertical, -9)
                    .padding(.horizontal, -5)
            }
            .padding(.horizontal, 5)

            VStack(alignment: .leading, spacing: 0) {
                Text("Price")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 0) {
                    TextField("Item price", text: $priceString.onChange(update), prompt: Text("0,00"))
                        .keyboardType(.decimalPad)
                    
                    Text("€")
                }

                if let type = item.type {
                    Text("Quantity")
                        .font(.caption)
                        .padding(.top, 5)
                        .foregroundColor(.secondary)

                    HStack(spacing: 0) {
                        TextField("Quantity", text: $quantityString.onChange(update), prompt: Text("0,00"))
                            .keyboardType(.decimalPad)

                        Text(type.unit.abbreviation)
                    }

                    Text("Per unit")
                        .font(.caption)
                        .padding(.top, 5)
                        .foregroundColor(.secondary)

                    HStack(spacing: 0) {
                        Text(item.perUnitString)
                        Spacer()
                        Text("€")
                    }
                }
            }
            .padding(.bottom, 5)
            .frame(width: 70)
        }
        .padding(.vertical, 4)
    }
}

struct ReceiptItemView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        Form {
            ItemView(item: Item.example)
        }
    }
}
