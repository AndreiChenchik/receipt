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
    
    @Published var scanImage: UIImage

    init(with scanImage: UIImage) {
        self.scanImage = scanImage
    }
}
