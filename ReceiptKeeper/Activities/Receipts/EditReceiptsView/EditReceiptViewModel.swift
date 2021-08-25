//
//  EditReceiptViewModel.swift
//  EditReceiptViewModel
//
//  Created by Andrei Chenchik on 25/8/21.
//

import Foundation

extension EditReceiptView {
    class ViewModel: ObservableObject {
        let receipt: Receipt
        let dataController: DataController

        init(receipt: Receipt, dataController: DataController) {
            self.receipt = receipt
            self.dataController = dataController

            self.title = receipt.vendor?.title ?? ""
            self.total = receipt.total?.stringValue ?? ""
            self.purchaseDate = receipt.purchaseDate ?? Date()
        }

        @Published var title: String
        @Published var total: String
        @Published var purchaseDate: Date {
            didSet {
                receipt.purchaseDate = purchaseDate
            }
        }


        func update() {
            print("title changed!")
        }

        func saveChanges() {
            dataController.saveIfNeeded()
        }
    }
}
