//
//  DataController.swift
//  DataController
//
//  Created by Andrei Chenchik on 7/8/21.
//

import Combine
import CoreData
import Foundation
import UIKit

class DataController: ObservableObject {
    static let shared = DataController()
    
    /// A CloudKit container used to store all our data
    let container: NSPersistentCloudKitContainer
    var backgroundContext: NSManagedObjectContext

    /// Initializes a data controller, either in memory (for temporary use such as testing and previewing),
    /// or on permanent storage (for use in regular app runs.)
    ///
    /// Defaults to permanent storage.
    /// - Parameter inMemory: Whether to store this data in temporary memory or not.
    init(inMemory: Bool = false) {
        ValueTransformer.setValueTransformer(RecognitionDataTransformer(), forName: .recognitionDataTransformer)

        container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)

        self.backgroundContext = container.newBackgroundContext()

        // For testing and previewing purposes, we create a temporary,
        // in-memory database by writing to /dev/null so our data is
        // destroyed after the app finishes running.
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }

            self.container.viewContext.automaticallyMergesChangesFromParent = true
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

            self.backgroundContext.automaticallyMergesChangesFromParent = true
            self.backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        }
    }

    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
            fatalError("Failed to locate model file.")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model file.")
        }

        return managedObjectModel
    }()

    /// Saves our CoreData context iff there are changes. This will rollback if
    /// any errors caused by saving.
    /// - Parameter context: in what context should changes be saved,
    /// will default to viewContext.
    func saveIfNeeded(in context: NSManagedObjectContext? = nil) {
        let context = context ?? container.viewContext

        do {
            try context.saveIfChanges()
        } catch {
            print(error)
            let error = error
            fatalError("Error saving your data: \(error.localizedDescription)")
            //context.rollback()
        }
    }

    /// Delete CoreData object from storage
    func delete(_ object: NSManagedObject) {
        container.viewContext.delete(object)
    }

    func delete(_ objectIDs: [NSManagedObjectID]) {
        backgroundContext.performAndWait {
            for objectID in objectIDs {
                if let object = try? backgroundContext.existingObject(with: objectID) {
                    backgroundContext.delete(object)
                }
            }

            do {
                try backgroundContext.saveIfChanges()
            } catch {
                fatalError("Error deleting objects: \(error.localizedDescription)")
            }
        }
    }
}


