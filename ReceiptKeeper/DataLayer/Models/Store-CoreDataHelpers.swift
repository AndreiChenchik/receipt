//
//  Store-CoreDataHelpers.swift
//  Store-CoreDataHelpers
//
//  Created by Andrei Chenchik on 29/8/21.
//

import Foundation

extension Store {
    var wrappedTitle: String { title ?? "❓ Unknown store" }

    var storeIcon: String? {
        if let firstChar = wrappedTitle.first, firstChar.isEmoji {
            return String(firstChar)
        }

        return nil
    }

    var storeTitleWithoutIcon: String {
        if storeIcon != nil {
            let shortTitle = wrappedTitle.dropFirst().trimmingCharacters(in: .whitespacesAndNewlines)
            return String(shortTitle)
        } else {
            return wrappedTitle
        }
    }

    var storeReceipts: [Receipt] {
        receipts?.allObjects as? [Receipt] ?? []
    }

    var storeItems: [Item] {
        storeReceipts.reduce([]) { partialResult, receipt in
            partialResult + receipt.receiptItems
        }
    }

    var storeReceiptsSum: NSDecimalNumber {
        let sum = storeReceipts.reduce(0.0) { partialResult, receipt in
            partialResult + (receipt.total?.doubleValue ?? 0.0)
        }

        return NSDecimalNumber(value: sum)
    }

    var storeReceiptsSumString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: storeReceiptsSum) ?? ""
    }
}

extension Store {
    static var example: Store {
        let controller = DataController.preview
        let viewContext = controller.container.viewContext

        let store = Store(context: viewContext)
        store.title = "🛃 Store example"

        return store
    }
}
