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
    @Published var scanImage: UIImage
    @Published var dateCreated = Date()

    init(with scanImage: UIImage) {
        self.scanImage = scanImage
    }
}
