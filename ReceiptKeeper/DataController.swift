//
//  DataController.swift
//  DataController
//
//  Created by Andrei Chenchik on 7/8/21.
//

import Foundation
import UIKit

class DataController: ObservableObject {
    @Published var receipts = [Receipt]()
    @Published var drafts = [Draft]()

    init() {
        print("initialized")
    }

    func addReceiptDraft(with scanImage: UIImage) {
        let draft = Draft(with: scanImage)
        drafts.append(draft)
    }
}
