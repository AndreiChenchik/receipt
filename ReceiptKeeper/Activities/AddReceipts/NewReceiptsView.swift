//
//  NewReceiptsView.swift
//  NewReceiptsView
//
//  Created by Andrei Chenchik on 4/8/21.
//

import SwiftUI

struct NewReceiptsView: View {
    @EnvironmentObject var recognizer: Recognizer
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            List {
                ForEach(0..<recognizer.receiptScans.count) { index in
                    Section {
                        NavigationLink(destination: RecognitionResultsView(index: index)) {
                            NewReceiptCellView(scan: recognizer.receiptScans[index])
                        }
                    }
                }
            }
        }
        .navigationTitle("New receipts")
    }


    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

//struct AddReciept_Previews: PreviewProvider {
//    static var previews: some View {
//        NewReceiptsView()
//    }
//}
