//
//  ReceiptLine.swift
//  ReceiptLine
//
//  Created by Andrei Chenchik on 10/8/21.
//

import Foundation
import CoreGraphics

struct ReceiptLine: Identifiable, Equatable {
    static func == (lhs: ReceiptLine, rhs: ReceiptLine) -> Bool {
        lhs.id == rhs.id
    }

    let id = UUID()

    var label: String
    var value: String
    var selected: Bool

    var boundingBox: CGRect

    var text: String { label + " " + value }

    init(label: String, value: String, selected: Bool, boundingBox: CGRect) {
        self.label = label
        self.value = value
        self.selected = selected
        self.boundingBox = boundingBox
    }
}
