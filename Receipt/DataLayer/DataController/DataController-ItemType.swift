//
//  DataController-GoodsType.swift
//  DataController-GoodsType
//
//  Created by Andrei Chenchik on 3/9/21.
//

import CoreData
import Foundation

extension DataController {
    func createGoodsType(with title: String, linkedTo itemID: NSManagedObjectID?) {
        backgroundContext.performWaitAndSave {
            let type = GoodsType(context: backgroundContext)
            type.title = title

            if let itemID = itemID,
               let item = try? self.backgroundContext.existingObject(with: itemID) as? Item {
                
                item.type = type
            }
        }
    }

    func updateGoodsType(_ typeID: NSManagedObjectID, title: String) {
        backgroundContext.performWaitAndSave {
            if let type = try? self.backgroundContext.existingObject(with: typeID) as? GoodsType {

                type.title = title
            }
        }
    }
}
