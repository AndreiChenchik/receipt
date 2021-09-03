//
//  ItemType-CoreDataHelpers.swift
//  ItemType-CoreDataHelpers
//
//  Created by Andrei Chenchik on 1/9/21.
//

import Foundation

extension ItemType {
    var typeTitle: String { title ?? "Unknown category" }

    var typeIcon: String {
        String(title?.first ?? Character(""))
    }

    var typeTitleWithoutIcon: String {
        if typeIcon.first?.isEmoji ?? false {
            let shortTitle = typeTitle.dropFirst().trimmingCharacters(in: .whitespacesAndNewlines)
            return String(shortTitle)
        } else {
            return typeTitle
        }
    }

    var typeItems: [Item] {
        items?.allObjects as? [Item] ?? []
    }

    var typeItemsSum: NSDecimalNumber {
        let sum = typeItems.reduce(0.0) { partialResult, receipt in
            partialResult + (receipt.price?.doubleValue ?? 0.0)
        }

        return NSDecimalNumber(value: sum)
    }

    var typeItemsSumString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: typeItemsSum) ?? ""
    }
}

extension ItemType {
    static var example: ItemType {
        let controller = DataController.preview
        let viewContext = controller.container.viewContext

        let vendor = ItemType(context: viewContext)
        vendor.title = "🛃 Example Category"

        return vendor
    }
}
