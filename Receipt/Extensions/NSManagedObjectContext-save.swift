//
//  NSManagedObjectContext.swift
//  NSManagedObjectContext
//
//  Created by Andrei Chenchik on 3/9/21.
//

import CoreData

extension NSManagedObjectContext {
    func performWaitAndSave(_ block: () -> Void) {
        self.performAndWait {
            block()

            do {
                try self.saveIfChanges()
            } catch {
                fatalError("Error saving data: \(error.localizedDescription)")
            }
        }
    }

    func saveIfChanges() throws {
        guard hasChanges else { return }
        try save()
    }
}
