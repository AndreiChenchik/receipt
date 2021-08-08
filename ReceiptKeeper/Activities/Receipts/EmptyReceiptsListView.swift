//
//  EmptyReceiptsListView.swift
//  EmptyReceiptsListView
//
//  Created by Andrei Chenchik on 7/8/21.
//

import SwiftUI

struct EmptyReceiptsListView: View {
    var body: some View {
        VStack {
            Text("No receipts to display")
            Text("Start by scanning new receipts")
        }
    }
}

struct EmptyReceiptListView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyReceiptsListView()
    }
}
