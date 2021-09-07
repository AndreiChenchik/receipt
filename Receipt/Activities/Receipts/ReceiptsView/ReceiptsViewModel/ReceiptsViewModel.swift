//
//  ReceiptsViewModel.swift
//  ReceiptsViewModel
//
//  Created by Andrei Chenchik on 7/8/21.
//

import CoreData
import UIKit

extension ReceiptsView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        let dataController = DataController.shared
        let receiptsController: NSFetchedResultsController<Receipt>

        @Published var allReceipts = [Receipt]()
        var draftReceipts: [Receipt] { allReceipts.filter { $0.state == .draft || $0.state == .processing } }
        var readyReceipts: [Receipt] { allReceipts.filter { $0.state == .ready } }

        @Published var newScanImages = [UIImage]()

        override init() {
            let request = Receipt.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Receipt.creationDate, ascending: false)]
            
            receiptsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            super.init()

            receiptsController.delegate = self

            do {
                try receiptsController.performFetch()
                allReceipts = receiptsController.fetchedObjects ?? []
            } catch {
                print("Error fetching receipts array: \(error.localizedDescription)")
            }
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newReceipts = controller.fetchedObjects as? [Receipt] {
                allReceipts = newReceipts
            }
        }

        func delete(_ object: NSManagedObject) {
            dataController.delete(object)
            dataController.saveIfNeeded()
        }

        var isCapableToScan: Bool {
            ScannerView.isCapableToScan
        }

        func createReceipt() {
            dataController.createReceipt()
        }
    }
}
