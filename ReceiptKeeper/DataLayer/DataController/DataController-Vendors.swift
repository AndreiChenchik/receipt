//
//  DataController-Stores.swift
//  DataController-Stores
//
//  Created by Andrei Chenchik on 3/9/21.
//

import Foundation
import CoreData

extension DataController {
    func createStore(with title: String, linkedTo receiptID: NSManagedObjectID?) {
        backgroundContext.performWaitAndSave {
            let store = Store(context: backgroundContext)
            store.title = title

            if let receiptID = receiptID,
               let receipt = try? self.backgroundContext.existingObject(with: receiptID) as? Receipt {

                receipt.store = store
            }
        }
    }

    func updateStore(_ storeID: NSManagedObjectID, title: String) {
        backgroundContext.performWaitAndSave {
            if let store = try? self.backgroundContext.existingObject(with: storeID) as? Store {

                store.title = title
            }
        }

        #warning("should be refactored, because it can be slow when there will be a lot of receipts")
        container.viewContext.perform {
            if let store = try? self.container.viewContext.existingObject(with: storeID) as? Store {

                for receipt in store.storeReceipts {
                    receipt.objectWillChange.send()
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
