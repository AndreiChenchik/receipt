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
        VStack(alignment: .leading, spacing: 6) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    Text(title)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(Font.body.weight(.bold))
                        .opacity(0)
                        .layoutPriority(1)

                    TextEditor(text: $title.onChange(update))
                        .font(Font.body.weight(.bold))
                        .padding(.vertical, -9)
                        .padding(.horizontal, -5)
                }
                .padding(.horizontal, 5)

                Divider()
            }


            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Price")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 0) {
                            TextField("Item price", text: $priceString.onChange(update), prompt: Text("0,00"))
                                .keyboardType(.decimalPad)
                                .padding(5)

                            Divider()
                        }
                        .frame(width: 50)
                        .padding(.trailing, 5)

                        Text("€")
                    }

                }
                .padding(.trailing, 25)

                if let type = item.type {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(type.unit.title)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        HStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 0) {
                                TextField("Quantity", text: $quantityString.onChange(update), prompt: Text("0,00"))
                                    .keyboardType(.decimalPad)

                                    .padding(5)
                                    .padding(.trailing, 5)

                                Divider()
                            }
                            .frame(width: 50)
                            .padding(.trailing, 5)
                        }
                    }
                }

                Spacer()

                VStack(alignment: .leading, spacing: 2) {
                    Text("Type")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    GoodsTypePicker(item: item)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(.tertiarySystemFill).opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .frame(maxWidth: 150, alignment: .leading)

            }

            if let type = item.type, let quantity = item.quantity, quantity != 0 {
                HStack {
                    HStack(spacing: 4) { Image(systemName: "chart.bar.fill")
                        Text("\(item.perUnitString) € per \(type.unit.abbreviation)")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(5)
                    .background(Color(.systemGray6).opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                }
            }
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
