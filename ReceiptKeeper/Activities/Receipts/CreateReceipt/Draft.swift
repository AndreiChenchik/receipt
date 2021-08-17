//
//  Draft.swift
//  Draft
//
//  Created by Andrei Chenchik on 7/8/21.
//

import Foundation
import UIKit
import Combine

class Draft: Identifiable, ObservableObject {
    let id = UUID()

    var dateCreated = Date()

    @Published var transactionDate = DraftDateTime(Date())
    
    @Published var scanImage: UIImage?
    @Published var scanTextBoxesLayer: UIImage?
    @Published var scanCharBoxesLayer: UIImage?

    @Published var storeTitle = ""
    @Published var storeAddress = ""
    @Published var totalValue = ""

    @Published var draftLines = [DraftLine]()
    var selectedReceiptLines: [DraftLine] { draftLines.filter { $0.selected } }
    var unselectedReceiptLines: [DraftLine] { draftLines.filter { !$0.selected } }

    init(with scanImage: UIImage) {
        self.scanImage = scanImage
    }
}
