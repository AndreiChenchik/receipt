//
//  NewReceiptCellView.swift
//  NewReceiptCellView
//
//  Created by Andrei Chenchik on 6/8/21.
//

import SwiftUI

struct NewReceiptCellView: View {
    let scan: ReceiptScan

    var body: some View {
        ZStack {
            Image(uiImage: scan.scanImage)
                .resizable()
                .scaledToFill()

            if scan.recognizedImage != nil {
                Color.green.opacity(0.2)
            }
        }
        .frame(height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .padding(5)
    }
}

//struct NewReceiptCellView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewReceiptCellView()
//    }
//}
