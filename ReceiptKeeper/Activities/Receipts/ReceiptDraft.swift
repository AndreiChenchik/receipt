//
//  ReceiptDraft.swift
//  ReceiptDraft
//
//  Created by Andrei Chenchik on 7/8/21.
//

import Foundation
import UIKit

struct ReceiptDraft: Identifiable {
    let id = UUID()
    let image: UIImage
    let dateCreated = Date()
}
