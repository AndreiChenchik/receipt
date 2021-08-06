//
//  ReceiptScan.swift
//  ReceiptScan
//
//  Created by Andrei Chenchik on 6/8/21.
//

import Foundation
import UIKit

struct ReceiptScan: Identifiable {
    let id = UUID()
    let scanImage: UIImage
    var recognizedImage: UIImage? = nil
}
