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
import MapKit

extension EditReceiptView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        let dataController: DataController
        let vendorsController: NSFetchedResultsController<Vendor>

        @Published var receipt: Receipt

        @Published var vendors = [Vendor]()

        @Published var venueTitle = ""
        @Published var receiptVendor = Vendor() {
            didSet {
                guard receiptVendor != receipt.vendor else { return }

                receipt.vendor = receiptVendor
                dataController.saveIfNeeded()
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

            if let vendor = receipt.vendor {
                receiptVendor = vendor
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
            
            let vendorsRequest = Vendor.fetchRequest()
            vendorsRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Vendor.title, ascending: false)]

            vendorsController = NSFetchedResultsController(
                fetchRequest: vendorsRequest,
                managedObjectContext: dataController.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            super.init()

            withAnimation {
                updateFormFields(from: receipt)

            }

            fetchVendors()
            vendorsController.delegate = self

            dataController.publisher(for: receipt, in: dataController.viewContext, changeTypes: [.updated])
                .sink(receiveValue: { [weak self] change in
                    guard let updatedReceipt = change.object else { return }
                    self?.updateFormFields(from: updatedReceipt)
                })
                .store(in: &cancellables)
        }

        func fetchVendors() {
            do {
                try vendorsController.performFetch()
                vendors = vendorsController.fetchedObjects ?? []
            } catch {
                print("Error fetching receipts array: \(error.localizedDescription)")
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
