//
//  EditReceiptViewModel.swift
//  EditReceiptViewModel
//
//  Created by Andrei Chenchik on 25/8/21.
//

import Foundation

extension EditReceiptView {
    class ViewModel: ObservableObject {
        @Published var receipt: Receipt
        let dataController: DataController

        init(receipt: Receipt, dataController: DataController) {
            self.receipt = receipt
            self.dataController = dataController
        }

        func saveChanges() {
            dataController.saveIfNeeded()
        }

        func addItem() {
            let item = Item(context: dataController.viewContext)
            item.receipt = receipt
            saveChanges()
        }
    }
}
