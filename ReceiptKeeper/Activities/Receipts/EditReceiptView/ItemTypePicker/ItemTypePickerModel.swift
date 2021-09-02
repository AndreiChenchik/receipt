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
        let dataController: DataController
        let resultsController: NSFetchedResultsController<ItemType>

        @Published var item: Item

        var selectedTypeIcon: String { item.type?.typeIcon ?? "❓" }
        @Published var selectedTypeIndex = -1 {
            didSet {
                if selectedTypeIndex != -1 {
                    item.type = types[selectedTypeIndex]
                } else {
                    item.type = nil
                }

                dataController.saveIfNeeded()
            }
        }

        @Published var types = [ItemType]() {
            didSet {
                let newTypeIndex = types.firstIndex { item.type == $0 } ?? -1

                if newTypeIndex != selectedTypeIndex {
                    selectedTypeIndex = newTypeIndex
                }
            }
        }

        init(item: Item, dataController: DataController) {
            self.dataController = dataController
            self.item = item
            
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
