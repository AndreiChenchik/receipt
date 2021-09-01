//
//  TypesViewModel.swift
//  TypesViewModel
//
//  Created by Andrei Chenchik on 1/9/21.
//

import Foundation
import CoreData

extension TypesView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        let dataController: DataController
        let resultsController: NSFetchedResultsController<ItemType>

        @Published var types = [ItemType]()

        init(dataController: DataController) {
            self.dataController = dataController

            let request = ItemType.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \ItemType.title, ascending: false)]

            resultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: dataController.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            super.init()

            resultsController.delegate = self

            do {
                try resultsController.performFetch()
                types = resultsController.fetchedObjects ?? []
            } catch {
                print("Error fetching vendors array: \(error.localizedDescription)")
            }
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newTypes = controller.fetchedObjects as? [ItemType] {
                types = newTypes
            }
        }

        func deleteItemType(indexSet: IndexSet) {
            for index in indexSet.reversed() {
                dataController.delete(types[index])
            }

            dataController.saveIfNeeded()
        }
    }
}
