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
                        item.quantity = 1
                        item.price = NSDecimalNumber(value: itemLine.value ?? 0)
                        item.creationDate = Date()
                    }

                    if receipt.storeLineUUID != recognitionData.venueTitle?.id,
                       let title = recognitionData.venueTitle?.value,
                       let store = self.searchStore(for: title, in: context) {
                        receipt.store = store
                        receipt.storeLineUUID = recognitionData.venueTitle?.id
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

    func updateReceipt(_ receiptID: NSManagedObjectID, storeID: NSManagedObjectID?) {
        backgroundContext.performWaitAndSave {
            guard let receipt = try? self.backgroundContext.existingObject(with: receiptID) as? Receipt else { return }

            if let storeID = storeID,
                let store = try? self.backgroundContext.existingObject(with: storeID) as? Store {

                receipt.store = store
            } else {
                receipt.store = nil
            }
        }
    }

    func updateReceipt(_ receiptID: NSManagedObjectID, storeURL: String) {
        backgroundContext.performWaitAndSave {
            if let receipt = try? self.backgroundContext.existingObject(with: receiptID) as? Receipt,
               let storeURL = URL(string: storeURL),
               let storeID = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: storeURL),
               let store = try? self.backgroundContext.existingObject(with: storeID) as? Store {

                receipt.store = store
            }
        }
    }
}
