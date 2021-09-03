//
//  DataController-Receipts.swift
//  DataController-Receipts
//
//  Created by Andrei Chenchik on 24/8/21.
//

import UIKit
import CoreData

extension DataController {
    func createReceipt(with scanImage: UIImage? = nil, _ completionHandler: @escaping (NSManagedObjectID) -> Void = {_ in}) {
        container.performBackgroundTask { context in
            let receipt = Receipt(context: context)
            receipt.creationDate = Date()

            if let scanImage = scanImage {
                receipt.scanImage = scanImage
                receipt.state = .processing
            } else {
                receipt.state = .draft
            }

            self.saveIfNeeded(in: context)
            completionHandler(receipt.objectID)
        }
    }

    func updateReceipt(withID receiptObjectID: NSManagedObjectID, from recognizedContent: RecognizedContent?, _ completionHandler: @escaping () -> Void = {}) {
        container.performBackgroundTask { context in
            if let receipt = try? context.existingObject(with: receiptObjectID) as? Receipt {
                if let recognizedContent = recognizedContent {
                    let recognitionData = RecognitionData(content: recognizedContent)
                    receipt.recognitionData = recognitionData

                    if receipt.purchaseDateLineUUID != recognitionData.purchaseDate?.id {
                        receipt.purchaseDate = recognitionData.purchaseDate?.value
                        receipt.purchaseDateLineUUID = recognitionData.purchaseDate?.id
                    }

                    if receipt.totalLineUUID != recognitionData.receiptTotal?.id {
                        receipt.total = recognitionData.receiptTotal?.value
                        receipt.totalLineUUID = recognitionData.receiptTotal?.id
                    }

                    if receipt.venueAddressLineUUID != recognitionData.venueAddress?.id {
                        receipt.venueAddress = recognitionData.venueAddress?.value
                        receipt.venueAddressLineUUID = recognitionData.venueAddress?.id
                    }

                    if receipt.purchaseDateLineUUID != recognitionData.purchaseDate?.id {
                        receipt.purchaseDate = recognitionData.purchaseDate?.value
                        receipt.purchaseDateLineUUID = recognitionData.purchaseDate?.id
                    }

                    let cartItemsLineUUIDS = receipt.receiptItems.compactMap { $0.recognizedLineUUID }
                    let newItemLines = recognitionData.content.lines.filter { $0.contentType == .item && !cartItemsLineUUIDS.contains($0.id)}
                    for itemLine in newItemLines {
                        let item = Item(context: context)
                        item.receipt = receipt
                        item.recognizedLineUUID = itemLine.id
                        item.title = itemLine.label
                        item.price = NSDecimalNumber(value: itemLine.value ?? 0)
                        item.creationDate = Date()
                    }

                    if receipt.vendorLineUUID != recognitionData.venueTitle?.id,
                       let title = recognitionData.venueTitle?.value,
                       let vendor = self.searchVendor(for: title, in: context) {
                        receipt.vendor = vendor
                        receipt.vendorLineUUID = recognitionData.venueTitle?.id
                    }

                    if receipt.state == .processing {
                        receipt.state = .draft
                    }
                }

                self.saveIfNeeded(in: context)
            }

            completionHandler()
        }
    }

    func updateReceipt(_ receiptID: NSManagedObjectID, vendorID: NSManagedObjectID?) {
        backgroundContext.performWaitAndSave {
            guard let receipt = try? self.backgroundContext.existingObject(with: receiptID) as? Receipt else { return }

            if let vendorID = vendorID,
                let vendor = try? self.backgroundContext.existingObject(with: vendorID) as? Vendor {

                receipt.vendor = vendor
            } else {
                receipt.vendor = nil
            }
        }
    }

    func updateReceipt(_ receiptID: NSManagedObjectID, vendorURL: String) {
        backgroundContext.performWaitAndSave {
            if let receipt = try? self.backgroundContext.existingObject(with: receiptID) as? Receipt,
               let vendorURL = URL(string: vendorURL),
               let vendorID = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: vendorURL),
               let vendor = try? self.backgroundContext.existingObject(with: vendorID) as? Vendor {

                receipt.vendor = vendor
            }
        }
    }
}
