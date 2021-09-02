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
                       let vendor = searchVendor(for: title, in: context) {
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

        func searchVendor(for title: String, in context: NSManagedObjectContext) -> Vendor? {
            let vendorsRequest = Vendor.fetchRequest()
            vendorsRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Vendor.title, ascending: false)]

            let vendorsController = NSFetchedResultsController(
                fetchRequest: vendorsRequest,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            do {
                try vendorsController.performFetch()
                let vendors = vendorsController.fetchedObjects ?? []
                let receiptVendor = vendors.first { !$0.vendorTitleWithoutIcon.isEmpty && title.lowercased().contains($0.vendorTitleWithoutIcon.lowercased()) }
                return receiptVendor
            } catch {
                print("Error fetching receipts array: \(error.localizedDescription)")
            }

            return nil
        }
    }
}
