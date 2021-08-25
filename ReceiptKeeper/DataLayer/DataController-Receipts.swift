//
//  DataController-Receipts.swift
//  DataController-Receipts
//
//  Created by Andrei Chenchik on 24/8/21.
//

import UIKit
import CoreData

extension DataController {
    func save(in context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            print("Error saving your data: \(error.localizedDescription)")
            context.rollback()
        }
    }

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

            self.save(in: context)
            completionHandler(receipt.objectID)
        }
    }

    func updateReceipt(withID receiptObjectID: NSManagedObjectID, from recognizedContent: RecognizedContent?, _ completionHandler: @escaping () -> Void = {}) {
        container.performBackgroundTask { context in
            if let receipt = try? context.existingObject(with: receiptObjectID) as? Receipt {
                if let recognizedContent = recognizedContent {
                    receipt.recognitionData = RecognitionData(content: recognizedContent)
                }

                receipt.state = .draft

                self.save(in: context)
            }

            completionHandler()
        }
    }
}
