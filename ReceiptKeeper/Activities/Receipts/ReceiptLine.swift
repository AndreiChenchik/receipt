//
//  ReceiptLine.swift
//  ReceiptLine
//
//  Created by Andrei Chenchik on 10/8/21.
//

import Foundation
import CoreGraphics

class ReceiptLine: ObservableObject, Identifiable, Equatable {
    static func == (lhs: ReceiptLine, rhs: ReceiptLine) -> Bool {
        lhs.id == rhs.id
    }

    let id = UUID()

    @Published var label: String
    @Published var value: String
    @Published var selected: Bool

    @Published var boundingBox: CGRect

    var text: String { label + " " + value }

    init(label: String, value: String, selected: Bool, boundingBox: CGRect) {
        self.label = label
        self.value = value
        self.selected = selected
        self.boundingBox = boundingBox
    }
}
