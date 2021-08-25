//
//  DataController.swift
//  DataController
//
//  Created by Andrei Chenchik on 7/8/21.
//

import CoreData
import Foundation
import UIKit

class DataController: ObservableObject {
    /// A CloudKit container used to store all our data
    let container: NSPersistentCloudKitContainer

    /// A viewContext for CloudKit container
    var viewContext: NSManagedObjectContext { container.viewContext }

    /// Initializes a data controller, either in memory (for temporary use such as testing and previewing),
    /// or on permanent storage (for use in regular app runs.)
    ///
    /// Defaults to permanent storage.
    /// - Parameter inMemory: Whether to store this data in temporary memory or not.
    init(inMemory: Bool = false) {
        
        ValueTransformer.setValueTransformer(RecognitionDataTransformer(), forName: .recognitionDataTransformer)

        container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)

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

    /// Saves our CoreData context iff there are changes. This silently ignores
    /// any errors caused by saving, but this should be fine because our
    /// attributes are options.
    func saveIfNeeded() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Error saving your data: \(error.localizedDescription)")
                viewContext.rollback()
            }
        }
    }

    /// Delete CoreData object from storage
    func delete(_ object: NSManagedObject) {
        viewContext.delete(object)
    }
}

