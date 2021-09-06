//
//  DataController-Stores.swift
//  DataController-Stores
//
//  Created by Andrei Chenchik on 3/9/21.
//

import Foundation
import CoreData

extension DataController {
    func createStore(with title: String, linkedTo receiptID: NSManagedObjectID?, categoryID: NSManagedObjectID? = nil) {
        backgroundContext.performWaitAndSave {
            let store = Store(context: backgroundContext)
            store.title = title

            if let categoryID = categoryID,
               let category = try? self.backgroundContext.existingObject(with: categoryID) as? StoreCategory {

                store.category = category
            }

            if let receiptID = receiptID,
               let receipt = try? self.backgroundContext.existingObject(with: receiptID) as? Receipt {

                receipt.store = store
            }
        }
    }

    func updateStore(_ storeID: NSManagedObjectID, title: String, categoryID: NSManagedObjectID? = nil) {
        backgroundContext.performWaitAndSave {
            if let store = try? self.backgroundContext.existingObject(with: storeID) as? Store {

                store.title = title

                if let categoryID = categoryID,
                   let category = try? self.backgroundContext.existingObject(with: categoryID) as? StoreCategory {

                    store.category = category
                }
            }
        }
    }

    func searchStore(for title: String, in context: NSManagedObjectContext) -> Store? {
        let storesRequest = Store.fetchRequest()
        storesRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Store.title, ascending: false)]

        let storesController = NSFetchedResultsController(
            fetchRequest: storesRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        do {
            try storesController.performFetch()
            let stores = storesController.fetchedObjects ?? []
            let receiptStore = stores.first { !$0.storeTitleWithoutIcon.isEmpty && title.lowercased().contains($0.storeTitleWithoutIcon.lowercased()) }
            return receiptStore
        } catch {
            print("Error fetching receipts array: \(error.localizedDescription)")
        }

        return nil
    }
}
