//
//  ItemTypeViewModel.swift
//  ItemTypeViewModel
//
//  Created by Andrei Chenchik on 3/9/21.
//

import Foundation
import CoreData

extension ItemTypeView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        let dataController = DataController.shared
        let resultsController: NSFetchedResultsController<ItemCategory>

        @Published var categories = [ItemCategory]()

        override init() {
            let request = ItemCategory.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \ItemCategory.title, ascending: false)]

            resultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            super.init()

            resultsController.delegate = self

            fetchTypes()
        }

        func fetchTypes() {
            do {
                try resultsController.performFetch()
                categories = resultsController.fetchedObjects ?? []
            } catch {
                print("Error fetching stores array: \(error.localizedDescription)")
            }
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let categories = controller.fetchedObjects as? [ItemCategory] {
                self.categories = categories
            }
        }
    }
}
