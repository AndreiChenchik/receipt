//
//  EditReceiptViewModel.swift
//  EditReceiptViewModel
//
//  Created by Andrei Chenchik on 25/8/21.
//

import Combine
import CoreData
import Foundation
import SwiftUI

extension EditReceiptView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        let dataController: DataController
        let vendorsController: NSFetchedResultsController<Vendor>

        @Published var receipt: Receipt

        @Published var vendors = [Vendor]()


        @Published var venueTitle: String?
        var isShowingNewVendorAlert = false {
            didSet {
                if isShowingNewVendorAlert == false && receiptVendorIndex == -2 {
                    receiptVendorIndex = -1
                }
            }
        }
        @Published var receiptVendorIndex = -1 {
            didSet {
                guard receiptVendorIndex != -1 else { return }
                guard receipt.vendor?.uuid?.hashValue != receiptVendorIndex else { return }

                if receiptVendorIndex == -2 {
                    isShowingNewVendorAlert = true
                    return
                }

                if let receiptVendor = vendors.first(where: { $0.uuid?.hashValue == receiptVendorIndex }) {
                    receipt.vendor = receiptVendor
                    dataController.saveIfNeeded()
                }
            }
        }

        @Published var receiptTotal: String {
            didSet {
                guard receiptTotal != receipt.receiptTotal else { return }

                let formatter = NumberFormatter()
                formatter.generatesDecimalNumbers = true

                if let total = formatter.number(from: receiptTotal) as? NSDecimalNumber {
                    receipt.total = total

                    dataController.saveIfNeeded()
                } else {
                    receiptTotal = receipt.receiptTotal
                }
            }
        }
        
        @Published var receiptPurchaseDate: Date {
            didSet {
                guard receiptPurchaseDate != receipt.receiptPurchaseDate else { return }

                receipt.purchaseDate = receiptPurchaseDate

                dataController.saveIfNeeded()
            }
        }

        @Published var receiptPurchaseAddress: String {
            didSet {
                guard receiptPurchaseAddress != receipt.receiptPurchaseAddress else { return }

                receipt.venueAddress = receiptPurchaseAddress

                dataController.saveIfNeeded()
            }
        }

        private var cancellables = Set<AnyCancellable>()

        init(receipt: Receipt, dataController: DataController) {
            self.dataController = dataController

            self.receipt = receipt
            self.receiptTotal = receipt.receiptTotal
            self.receiptPurchaseDate = receipt.receiptPurchaseDate
            self.receiptPurchaseAddress = receipt.receiptPurchaseAddress
            self.receiptVendorIndex = receipt.vendor?.uuid?.hashValue ?? -1
            self.venueTitle = receipt.recognitionData?.venueTitile

            let vendorsRequest = Vendor.fetchRequest()
            vendorsRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Vendor.title, ascending: false)]

            vendorsController = NSFetchedResultsController(
                fetchRequest: vendorsRequest,
                managedObjectContext: dataController.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            super.init()


            fetchVendors()
            vendorsController.delegate = self

            dataController.publisher(for: receipt, in: dataController.viewContext, changeTypes: [.updated])
                .sink(receiveValue: { [weak self] change in
                    guard let updatedReceipt = change.object else { return }

                    self?.receipt.objectWillChange.send()
                    self?.receiptTotal = updatedReceipt.receiptTotal
                    self?.receiptPurchaseDate = updatedReceipt.receiptPurchaseDate
                    self?.receiptPurchaseAddress = updatedReceipt.receiptPurchaseAddress
                    self?.receiptVendorIndex = updatedReceipt.vendor?.uuid?.hashValue ?? -1
                    self?.venueTitle = updatedReceipt.recognitionData?.venueTitile
                })
                .store(in: &cancellables)
        }

        func fetchVendors() {
            do {
                try vendorsController.performFetch()
                vendors = vendorsController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch receipts: \(error.localizedDescription)")
            }
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newVendors = controller.fetchedObjects as? [Vendor] {
                vendors = newVendors
            }
        }

        func addItem() {
            let item = Item(context: dataController.viewContext)
            item.receipt = receipt

            dataController.saveIfNeeded()
        }

        func deleteItems(indexSet: IndexSet) {
            for index in indexSet.reversed() {
                let item = receipt.receiptItems[index]
                dataController.delete(item)
            }

            dataController.saveIfNeeded()
        }

        func addVendor(title: String) {
            let vendor = Vendor(context: dataController.viewContext)
            let uuid = UUID()

            vendor.title = title
            vendor.uuid = uuid

            receipt.vendor = vendor
            receiptVendorIndex = uuid.hashValue

            dataController.saveIfNeeded()
            fetchVendors()
        }
    }
}
