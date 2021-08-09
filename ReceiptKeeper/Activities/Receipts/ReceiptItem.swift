//
//  ReceiptItem.swift
//  ReceiptItem
//
//  Created by Andrei Chenchik on 9/8/21.
//

import Foundation

struct ReceiptItem: Identifiable {
    let id = UUID()
    let title: String
    let price: Double
}
