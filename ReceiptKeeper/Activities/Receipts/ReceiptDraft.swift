//
//  ReceiptDraft.swift
//  ReceiptDraft
//
//  Created by Andrei Chenchik on 7/8/21.
//

import Foundation
import UIKit

class ReceiptDraft: Identifiable, ObservableObject {
    let id = UUID()

    let dateCreated = Date()
    @Published var transactionDate = ""
    
    @Published var scanImage: UIImage
    @Published var scanTextBoxesLayer = UIImage()
    @Published var scanCharBoxesLayer = UIImage()

    @Published var storeTitle = ""
    @Published var storeAddress = ""
    @Published var totalValue = ""

    @Published var receiptLines = [ReceiptLine]()

    var selectedReceiptLines: [ReceiptLine] { receiptLines.filter { $0.selected } }
    var unselectedReceiptLines: [ReceiptLine] { receiptLines.filter { !$0.selected } }

    init(with scanImage: UIImage) {
        self.scanImage = scanImage
    }
}
