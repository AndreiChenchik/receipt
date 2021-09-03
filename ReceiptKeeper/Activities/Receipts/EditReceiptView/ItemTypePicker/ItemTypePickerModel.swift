//
//  ItemTypePickerModel.swift
//  ItemTypePickerModel
//
//  Created by Andrei Chenchik on 2/9/21.
//

import Foundation
import CoreData

extension ItemTypePicker {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        let dataController = DataController.shared
        let resultsController: NSFetchedResultsController<ItemType>

        @Published var item: Item

        var selectedTypeIcon: String { item.type?.typeIcon ?? "❓" }

        @Published var selectedTypeURL = "" { didSet { updateItem() } }
        @Published var types = [ItemType]()

        init(item: Item) {
            self.item = item
            selectedTypeURL = item.type?.objectURL ?? ""
            
            let request = ItemType.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \ItemType.title, ascending: false)]

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
                types = resultsController.fetchedObjects ?? []
                types.sort { $0.typeTitleWithoutIcon < $1.typeTitleWithoutIcon}
            } catch {
                print("Error fetching vendors array: \(error.localizedDescription)")
            }
        }

        func updateItem() {
            if selectedTypeURL == "" {
                dataController.updateItem(item.objectID, typeID: nil)
            } else {
                dataController.updateItem(item.objectID, typeURL: selectedTypeURL)
            }
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newTypes = controller.fetchedObjects as? [ItemType] {
                types = newTypes.sorted { $0.typeTitleWithoutIcon < $1.typeTitleWithoutIcon}
            }
        }
    }
}
