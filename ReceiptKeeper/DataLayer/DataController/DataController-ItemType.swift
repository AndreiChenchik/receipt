//
//  DataController-ItemType.swift
//  DataController-ItemType
//
//  Created by Andrei Chenchik on 3/9/21.
//

import CoreData
import Foundation

extension DataController {
    func createItemType(with title: String, linkedTo itemID: NSManagedObjectID?) {
        backgroundContext.performWaitAndSave {
            let type = ItemType(context: backgroundContext)
            type.title = title

            if let itemID = itemID,
               let item = try? self.backgroundContext.existingObject(with: itemID) as? Item {
                
                item.type = type
            }
        }
    }

    func updateItemType(_ typeID: NSManagedObjectID, title: String) {
        backgroundContext.performWaitAndSave {
            if let type = try? self.backgroundContext.existingObject(with: typeID) as? ItemType {

                type.title = title
            }
        }
    }
}
