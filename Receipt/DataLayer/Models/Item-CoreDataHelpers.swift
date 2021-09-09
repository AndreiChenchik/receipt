//
//  Item-CoreDataHelpers.swift
//  Item-CoreDataHelpers
//
//  Created by Andrei Chenchik on 29/8/21.
//

import Foundation

extension Item {
    var itemPriceString: String {
        guard let price = price else { return "" }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: price) ?? ""
    }

    var quantityString: String {
        guard let quantity = quantity else { return "" }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: quantity) ?? ""
    }

    var perUnitString: String {
        guard let quantity = quantity,
              let price = price
        else { return "" }

        guard quantity != 0 else { return "??" }

        let perUnit = price.dividing(by: quantity)

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: perUnit) ?? ""
    }


    var wrappedTitle: String { title ?? "Unknown item" }
}

extension Item {
    static var example: Item {
        let controller = DataController.preview
        let viewContext = controller.container.viewContext

        let item = Item(context: viewContext)
        item.title = "Nayeco Comedero Inox.\nN. Tiquet:\n-\nAntideslizante 300ml. 12cm G\nPVP Unid.: 4,95"
        item.creationDate = Date()
        item.quantity = 1

        let price = Double(Int.random(in: 0...499)) / 100.0
        item.price = NSDecimalNumber(value: price)

        return item
    }
}
