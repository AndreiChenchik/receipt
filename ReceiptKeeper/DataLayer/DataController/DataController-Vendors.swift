//
//  DataController-Vendors.swift
//  DataController-Vendors
//
//  Created by Andrei Chenchik on 3/9/21.
//

import Foundation
import CoreData

extension DataController {
    func createVendor(with title: String, linkedTo receiptID: NSManagedObjectID?) {
        backgroundContext.performWaitAndSave {
            let vendor = Vendor(context: backgroundContext)
            vendor.title = title

            if let receiptID = receiptID,
               let receipt = try? self.backgroundContext.existingObject(with: receiptID) as? Receipt {

                receipt.vendor = vendor
            }
        }
    }

    func updateVendor(_ vendorID: NSManagedObjectID, title: String) {
        backgroundContext.performWaitAndSave {
            if let vendor = try? self.backgroundContext.existingObject(with: vendorID) as? Vendor {

                vendor.title = title
            }
        }
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
