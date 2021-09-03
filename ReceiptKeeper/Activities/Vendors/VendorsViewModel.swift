//
//  VendorsViewModel.swift
//  VendorsViewModel
//
//  Created by Andrei Chenchik on 27/8/21.
//

import Foundation
import CoreData

extension VendorsView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        let dataController = DataController.shared
        let resultsController: NSFetchedResultsController<Vendor>

        @Published var vendors = [Vendor]()

        override init() {
            let request = Vendor.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Vendor.title, ascending: false)]

            resultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            super.init()

            resultsController.delegate = self

            do {
                try resultsController.performFetch()
                vendors = resultsController.fetchedObjects ?? []
            } catch {
                print("Error fetching vendors array: \(error.localizedDescription)")
            }
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newVendors = controller.fetchedObjects as? [Vendor] {
                vendors = newVendors
            }
        }

        func delete(indexSet: IndexSet) {
            let objectIDs = indexSet.map { vendors[$0].objectID }
            dataController.delete(objectIDs)
        }
    }
}
