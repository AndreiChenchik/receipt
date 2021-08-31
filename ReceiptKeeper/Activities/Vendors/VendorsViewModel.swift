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
        let dataController: DataController
        let resultsController: NSFetchedResultsController<Vendor>

        @Published var vendors = [Vendor]()

        init(dataController: DataController) {
            self.dataController = dataController

            let request = Vendor.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Vendor.title, ascending: false)]

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

        func deleteVendor(indexSet: IndexSet) {
            for index in indexSet.reversed() {
                dataController.delete(vendors[index])
            }

            dataController.saveIfNeeded()
        }
    }
}
