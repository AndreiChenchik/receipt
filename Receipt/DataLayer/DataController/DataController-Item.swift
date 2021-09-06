//
//  DataController-Item.swift
//  DataController-Item
//
//  Created by Andrei Chenchik on 3/9/21.
//

import CoreData
import Foundation

extension DataController {
    func updateItem(_ itemID: NSManagedObjectID, typeID: NSManagedObjectID?) {
        backgroundContext.performWaitAndSave {
            guard let item = try? self.backgroundContext.existingObject(with: itemID) as? Item else { return }

            if let typeID = typeID,
               let type = try? self.backgroundContext.existingObject(with: typeID) as? GoodsType {

                item.type = type
            } else {
                item.type = nil
            }
        }
    }


    func updateItem(_ itemID: NSManagedObjectID, typeURL: String) {
        backgroundContext.performWaitAndSave {
            if let item = try? self.backgroundContext.existingObject(with: itemID) as? Item,
               let typeURL = URL(string: typeURL),
               let typeID = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: typeURL),
               let type = try? self.backgroundContext.existingObject(with: typeID) as? GoodsType {

                item.type = type
            }
        }
    }
}
