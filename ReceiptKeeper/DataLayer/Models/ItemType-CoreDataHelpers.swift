//
//  GoodsType-CoreDataHelpers.swift
//  GoodsType-CoreDataHelpers
//
//  Created by Andrei Chenchik on 1/9/21.
//

import Foundation

extension GoodsType {
    var wrappedTitle: String { title ?? "Unknown category" }

    var typeIcon: String {
        String(title?.first ?? Character(""))
    }

    var typeTitleWithoutIcon: String {
        if typeIcon.first?.isEmoji ?? false {
            let shortTitle = wrappedTitle.dropFirst().trimmingCharacters(in: .whitespacesAndNewlines)
            return String(shortTitle)
        } else {
            return wrappedTitle
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

    var typeCategoryTitle: String {
        category?.title ?? "Unknown section"
    }
}

extension GoodsType {
    static var example: GoodsType {
        let controller = DataController.preview
        let viewContext = controller.container.viewContext

        let store = GoodsType(context: viewContext)
        store.title = "🛃 Example Category"

        return store
    }
}
