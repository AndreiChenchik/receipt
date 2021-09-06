//
//  ReceiptViewModel.swift
//  ReceiptViewModel
//
//  Created by Andrei Chenchik on 25/8/21.
//

import Combine
import CoreData
import Foundation
import SwiftUI
import MapKit

extension ReceiptView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        let dataController: DataController
        let storesController: NSFetchedResultsController<Store>

        @Published var receipt: Receipt

        @Published var venueTitle = ""

        @Published var stores = [Store]()
        @Published var selectedStoreURL = "" {
            didSet {
                if selectedStoreURL == "", receipt.store != nil {
                    dataController.updateReceipt(receipt.objectID, storeID: nil)
                } else if receipt.store?.objectURL != selectedStoreURL {
                    dataController.updateReceipt(receipt.objectID, storeURL: selectedStoreURL)
                }
            }
        }

        @Published var receiptTotal = "" {
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
        
        @Published var receiptPurchaseDate = Date() {
            didSet {
                guard receiptPurchaseDate != receipt.receiptPurchaseDate else { return }

                receipt.purchaseDate = receiptPurchaseDate

                dataController.saveIfNeeded()
            }
        }

        @Published var addressLocation: MKCoordinateRegion?
        @Published var receiptPurchaseAddress = "" {
            didSet {
                guard receiptPurchaseAddress != receipt.receiptPurchaseAddress else { return }

                receipt.venueAddress = receiptPurchaseAddress
                loadCoordinates(from: receiptPurchaseAddress)
                
                dataController.saveIfNeeded()
            }
        }

        private var cancellables = Set<AnyCancellable>()

        func getCoordinate( addressString : String,
                            completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
            DispatchQueue.global(qos: .userInitiated).async {
                let geocoder = CLGeocoder()
                geocoder.geocodeAddressString(addressString) { (placemarks, error) in
                    if error == nil {
                        if let placemark = placemarks?[0] {
                            let location = placemark.location!

                            completionHandler(location.coordinate, nil)
                            return
                        }
                    }

                    completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
                }
            }
        }


        func updateFormFields(from receipt: Receipt) {
            receiptTotal = receipt.receiptTotal
            receiptPurchaseDate = receipt.receiptPurchaseDate

            receiptPurchaseAddress = receipt.receiptPurchaseAddress
            loadCoordinates(from: receiptPurchaseAddress)

            fetchStores()

            let newStoreURL = receipt.store?.objectURL ?? ""
            if newStoreURL != selectedStoreURL {
                selectedStoreURL = newStoreURL
            }

            venueTitle = receipt.recognitionData?.venueTitle?.value ?? ""
        }

        func loadCoordinates(from addressString: String) {
            if !addressString.isEmpty {
                getCoordinate(addressString: receiptPurchaseAddress) { [weak self] coordinate, error in
                    DispatchQueue.main.async {
                        if error != nil || (coordinate.latitude == -180 && coordinate.longitude == -180) {
                            self?.addressLocation = nil
                        } else {
                            self?.addressLocation = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
                        }
                    }
                }
            }
        }

        init(receipt: Receipt, dataController: DataController) {
            self.dataController = dataController

            self.receipt = receipt
            
            let storesRequest = Store.fetchRequest()
            storesRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Store.title, ascending: false)]

            storesController = NSFetchedResultsController(
                fetchRequest: storesRequest,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            super.init()

            withAnimation {
                updateFormFields(from: receipt)
            }

            fetchStores()
            storesController.delegate = self

            dataController.publisher(for: receipt, in: dataController.container.viewContext, changeTypes: [.updated])
                .sink(receiveValue: { [weak self] change in
                    guard let updatedReceipt = change.object else { return }
                    self?.updateFormFields(from: updatedReceipt)
                })
                .store(in: &cancellables)
        }

        func fetchStores() {
            do {
                try storesController.performFetch()
                stores = storesController.fetchedObjects ?? []
            } catch {
                print("Error fetching receipts array: \(error.localizedDescription)")
            }
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newStores = controller.fetchedObjects as? [Store] {
                stores = newStores
            }
        }

        func addItem() {
            let item = Item(context: dataController.container.viewContext)
            item.creationDate = Date()
            item.receipt = receipt

            dataController.saveIfNeeded()
        }

        func deleteItems(indexSet: IndexSet) {
            for index in indexSet.reversed() {
                let item = receipt.receiptItemsSorted[index]

                if let line = receipt.recognitionData?.content.lines.first(where: { $0.id == item.recognizedLineUUID }) {
                    receipt.recognitionData = receipt.recognitionData?.withChangedLineContentType(for: line, to: .unknown)
                }

                dataController.delete(item)
            }

            dataController.saveIfNeeded()
        }

        var isShowingRecognizedData: Bool {
            receipt.recognitionData != nil
        }

        func saveReceipt() {
            receipt.state = .ready
            dataController.saveIfNeeded()
        }
    }
}
