//
//  ItemTypePickerModel.swift
//  ItemTypePickerModel
//
//  Created by Andrei Chenchik on 2/9/21.
//

import Foundation
import Combine
import CoreData

extension ItemTypePicker {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        let dataController = DataController.shared
        let resultsController: NSFetchedResultsController<ItemType>

        @Published var item: Item

        @Published var selectedTypeURL = "" { didSet { updateItem() } }
        @Published var types = [ItemType]()

        private var cancellables = Set<AnyCancellable>()

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
                print("Error fetching stores array: \(error.localizedDescription)")
            }

            dataController.publisher(for: item, in: dataController.container.viewContext, changeTypes: [.updated])
                .sink(receiveValue: { [weak self] change in
                    guard let updatedItem = change.object else { return }

                    let newTypeURL = updatedItem.type?.objectURL ?? ""
                    if newTypeURL != self?.selectedTypeURL {
                        self?.selectedTypeURL = newTypeURL
                    }
                })
                .store(in: &cancellables)
        }

        func updateItem() {
            if selectedTypeURL == "", item.type != nil {
                dataController.updateItem(item.objectID, typeID: nil)
            } else if item.type?.objectURL != selectedTypeURL {
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
