//
//  DataController-Previews.swift
//  DataController-Previews
//
//  Created by Andrei Chenchik on 30/8/21.
//

import Foundation

extension DataController {
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        let viewContext = dataController.container.viewContext

        do {
            try dataController.createSampleData()
        } catch {
            fatalError("Fatal error creating preview: \(error.localizedDescription)")
        }

        return dataController
    }()

    /// Creates example projects and items to make manual testing easier.
    /// - Throws: An NSError sent from calling save() on the NSManagedObjectContext.
    func createSampleData() throws {
        let viewContext = container.viewContext

        for vendorCounter in 1...3 {
            let vendor = Vendor(context: viewContext)
            vendor.title = "Vendor \(vendorCounter)"
            vendor.uuid = UUID()

            for _ in 1...3 {
                let receipt = Receipt(context: viewContext)
                receipt.vendor = vendor
                receipt.state = Receipt.State(rawValue: Int16.random(in: 1...3)) ?? .unknown
                var total = 0.0

                for itemCounter in 1...3 {
                    let item = Item(context: viewContext)
                    item.title = "Item \(itemCounter)"
                    let price = Double(itemCounter) + Double.random(in: 0...0.99)
                    item.price = NSDecimalNumber(value: price)
                    total += price
                }

                receipt.total = NSDecimalNumber(value: total)
            }
        }

        try viewContext.save()
    }
}
