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

            if let receiptID = receiptID {
                let receipt = try! self.backgroundContext.existingObject(with: receiptID) as! Receipt
                receipt.vendor = vendor
            }
        }
    }

    func updateVendor(_ vendorID: NSManagedObjectID, title: String) {
        backgroundContext.performWaitAndSave {
            let vendor = try! self.backgroundContext.existingObject(with: vendorID) as! Vendor
            vendor.title = title
        }
    }
}
