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
    enum ReceiptState: Int16 {
        case unknown = 0
        case processing = 1
        case draft = 2
        case ready = 3
    }

    /// An enum wrapper around **state** field
    var state: ReceiptState {
        get { ReceiptState(rawValue: stateValue) ?? .unknown }
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

    var totalString: String {
        get {
            total?.stringValue ?? "0"
        }

        set {
            total = NSDecimalNumber(string: newValue)
        }
    }

    var receiptVenueAddress: String {
        get {
            venueAddress ?? ""
        }

        set {
            venueAddress = newValue
        }
    }

    var receiptPurchaseDate: Date {
        get {
            purchaseDate ?? Date()
        }

        set {
            purchaseDate = newValue
        }
    }


    var receiptItems: [Item] {
        items?.allObjects as? [Item] ?? []
    }
}
