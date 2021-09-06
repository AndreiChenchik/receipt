//
//  DataController-GoodsType.swift
//  DataController-GoodsType
//
//  Created by Andrei Chenchik on 3/9/21.
//

import CoreData
import Foundation

extension DataController {
    func createGoodsType(with title: String, linkedTo itemID: NSManagedObjectID?, categoryID: NSManagedObjectID? = nil) {
        backgroundContext.performWaitAndSave {
            let type = GoodsType(context: backgroundContext)
            type.title = title

            if let categoryID = categoryID,
               let category = try? self.backgroundContext.existingObject(with: categoryID) as? GoodsCategory {

                type.category = category
            }

            if let itemID = itemID,
               let item = try? self.backgroundContext.existingObject(with: itemID) as? Item {
                
                item.type = type
            }
        }
    }

    func updateGoodsType(_ typeID: NSManagedObjectID, title: String, categoryID: NSManagedObjectID? = nil) {
        backgroundContext.performWaitAndSave {
            if let type = try? self.backgroundContext.existingObject(with: typeID) as? GoodsType {

                type.title = title

                if let categoryID = categoryID,
                   let category = try? self.backgroundContext.existingObject(with: categoryID) as? GoodsCategory {

                    type.category = category
                }
            }
        }
    }
}
