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
            let item = try! self.backgroundContext.existingObject(with: itemID) as! Item

            if let typeID = typeID {
                let type = try! self.backgroundContext.existingObject(with: typeID) as! ItemType
                item.type = type
            } else {
                item.type = nil
            }
        }
    }


    func updateItem(_ itemID: NSManagedObjectID, typeURL: String) {
        backgroundContext.performWaitAndSave {
            let item = try! self.backgroundContext.existingObject(with: itemID) as! Item
            let typeID = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: URL(string: typeURL)!)!
            let type = try! self.backgroundContext.existingObject(with: typeID) as! ItemType

            item.type = type
        }
    }
}
