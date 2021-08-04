//
//  Receipt.swift
//  Receipt
//
//  Created by Andrei Chenchik on 4/8/21.
//

import Foundation
import VisionKit

class Receipt: Identifiable {
    let id = UUID()
    var scanResult: Result<VNDocumentCameraScan, Error>

    init(from scanResult: Result<VNDocumentCameraScan, Error>) {
        self.scanResult = scanResult
    }
}
