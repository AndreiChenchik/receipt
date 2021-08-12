//
//  ReceiptsViewModel.swift
//  ReceiptsViewModel
//
//  Created by Andrei Chenchik on 7/8/21.
//

import Foundation

extension ReceiptsView {
    class ViewModel: ObservableObject {
        let dataController: DataController

        init(dataController: DataController) {
            self.dataController = dataController
        }

        var isCapableToScan: Bool {
            ScannerView.isCapableToScan
        }

        var haveReceiptsToShow: Bool {
            !dataController.drafts.isEmpty || !dataController.receipts.isEmpty
        }
    }
}
