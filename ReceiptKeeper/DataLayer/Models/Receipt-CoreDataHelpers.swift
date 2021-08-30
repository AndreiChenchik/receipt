//
//  Receipt-CoreDataHelpers.swift
//  Receipt
//
//  Created by Andrei Chenchik on 23/8/21.
//

import Foundation
import CoreData
import UIKit

extension Receipt {
    enum State: Int16 {
        case unknown = 0
        case processing = 1
        case draft = 2
        case ready = 3
    }

    /// An enum wrapper around **state** field
    var state: State {
        get { State(rawValue: stateValue) ?? .unknown }
        set { stateValue = newValue.rawValue }
    }

    /// A string representation of current **state**
    var stateString: String {
        let stateString: String

        switch state {
        case .unknown:
            stateString = "Unknown"
        case .processing:
            stateString = "Processing"
        case .draft:
            stateString = "Draft"
        case .ready:
            stateString = "Ready"
        }

        return stateString
    }

    /// A *UIImage* wrapper around **scanImageData** field
    var scanImage: UIImage? {
        get {
            if let scanImageData = scanImageData,
               let uiImage = UIImage(data: scanImageData) {
                return uiImage
            }

            return nil
        }

        set {
            if let newValue = newValue,
               let data = newValue.jpegData(compressionQuality: 0.0) {
                scanImageData = data
            }
        }
    }

    /// Wrapper around optional **creationDate** with
    /// nil value been replaced by current date and time
    var receiptCreationDate: Date {
        creationDate ?? Date()
    }

    var receiptPurchaseAddress: String { venueAddress ?? "" }
    var receiptPurchaseDate: Date { purchaseDate ?? Date() }
    var receiptTotal: String {
        guard let total = total else { return "" }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        return formatter.string(from: total) ?? ""
    }

    var receiptItems: [Item] {
        items?.allObjects as? [Item] ?? []
    }

    var receiptItemsSorted: [Item] {
        receiptItems.sorted { first, second in
            if let firstCreation = first.creationDate, let secondCreation = second.creationDate {
                return firstCreation < secondCreation
            } else {
                return first.itemTitle < second.itemTitle
            }
        }
    }

    var vendorTitle: String {
        vendor?.vendorTitle ?? "Unknown vendor"
    }

    var vendorTitleWithoutIcon: String {
        vendor?.vendorTitleWithoutIcon ?? "Unknown vendor"
    }
}


extension Receipt {
    static var example: Receipt {
        let controller = DataController.preview
        let viewContext = controller.container.viewContext

        let vendor = Vendor(context: viewContext)
        vendor.title = "🛃 Example Vendor"
        vendor.uuid = UUID()

        let receipt = Receipt(context: viewContext)
        receipt.vendor = vendor
        receipt.state = .draft
        receipt.creationDate = Date()
        receipt.purchaseDate = Date()
        var total = 0.0

        for itemCounter in 1...3 {
            let item = Item(context: viewContext)
            item.title = "Example Item \(itemCounter)"
            item.creationDate = Date()
            item.receipt = receipt

            let price = Double(itemCounter) + Double.random(in: 0...0.99)
            item.price = NSDecimalNumber(value: price)
            total += price
        }
        receipt.total = NSDecimalNumber(value: total)

        return receipt
    }
}
