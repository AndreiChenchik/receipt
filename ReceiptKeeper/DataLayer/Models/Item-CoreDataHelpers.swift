//
//  Item-CoreDataHelpers.swift
//  Item-CoreDataHelpers
//
//  Created by Andrei Chenchik on 29/8/21.
//

import Foundation

extension Item {
    var itemPriceString: String {
        guard let price = price else { return "" }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: price) ?? ""
    }
    var itemTitle: String { title ?? "Unknown item" }
}
