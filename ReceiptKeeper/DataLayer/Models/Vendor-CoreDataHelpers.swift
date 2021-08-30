//
//  Vendor-CoreDataHelpers.swift
//  Vendor-CoreDataHelpers
//
//  Created by Andrei Chenchik on 29/8/21.
//

import Foundation

extension Vendor {
    var vendorTitle: String { title ?? "Unknown vendor" }
    var vendorTag: String { uuid?.uuidString ?? "" }
}
