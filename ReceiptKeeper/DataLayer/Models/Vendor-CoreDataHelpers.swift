//
//  Vendor-CoreDataHelpers.swift
//  Vendor-CoreDataHelpers
//
//  Created by Andrei Chenchik on 29/8/21.
//

import Foundation

extension Vendor {
    var vendorTitle: String { title ?? "❓ Unknown vendor" }

    var vendorIcon: String? {
        if let firstChar = vendorTitle.first, firstChar.isEmoji {
            return String(firstChar)
        }

        return nil
    }

    var vendorTitleWithoutIcon: String {
        if vendorIcon != nil {
            let shortTitle = vendorTitle.dropFirst().trimmingCharacters(in: .whitespacesAndNewlines)
            return String(shortTitle)
        } else {
            return vendorTitle
        }
    }

    var vendorTag: String { uuid?.uuidString ?? "" }

    var vendorReceipts: [Receipt] {
        receipts?.allObjects as? [Receipt] ?? []
    }

    var vendorItems: [Item] {
        vendorReceipts.reduce([]) { partialResult, receipt in
            partialResult + receipt.receiptItems
        }
    }

    var vendorReceiptsSum: NSDecimalNumber {
        let sum = vendorReceipts.reduce(0.0) { partialResult, receipt in
            partialResult + (receipt.total?.doubleValue ?? 0.0)
        }

        return NSDecimalNumber(value: sum)
    }

    var vendorReceiptsSumString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: vendorReceiptsSum) ?? ""
    }
}
