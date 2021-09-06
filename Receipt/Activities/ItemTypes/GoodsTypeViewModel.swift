//
//  GoodsTypeViewModel.swift
//  GoodsTypeViewModel
//
//  Created by Andrei Chenchik on 3/9/21.
//

import Foundation
import CoreData

extension GoodsTypeView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        let dataController = DataController.shared
        let resultsController: NSFetchedResultsController<GoodsCategory>

        @Published var categories = [GoodsCategory]()

        override init() {
            let request = GoodsCategory.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \GoodsCategory.title, ascending: false)]

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
            if let categories = controller.fetchedObjects as? [GoodsCategory] {
                self.categories = categories
            }
        }
    }
}
