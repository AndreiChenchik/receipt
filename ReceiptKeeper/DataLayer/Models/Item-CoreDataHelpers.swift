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
    var itemTitle: String { title ?? "Unknown item" }
}

extension Item {
    static var example: Item {
        let controller = DataController.preview
        let viewContext = controller.container.viewContext

        let item = Item(context: viewContext)
        item.title = "6 x ESTRELLA DAMM LLAUNA"
        item.creationDate = Date()

        let price = Double.random(in: 0...4.99)
        item.price = NSDecimalNumber(value: price)

        return item
    }
}
