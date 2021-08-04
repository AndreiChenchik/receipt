//
//  ContentView.swift
//  ReceiptKeeper
//
//  Created by Andrei Chenchik on 4/8/21.
//

import SwiftUI
import VisionKit

struct ContentView: View {
    @State private var isShowingPicker = false
    @State private var isShowingAdder = false
    @State private var newReceipt: Receipt?

    var body: some View {
        Text("Hello, world!")
            .padding()
            .onTapGesture {
                isShowingPicker = true
            }
            .sheet(isPresented: $isShowingPicker) {
                ScanPicker(newReceipt: $newReceipt)
                    .ignoresSafeArea()
            }
            .sheet(item: $newReceipt, onDismiss: {
                newReceipt = nil
            }, content: AddReceipt.init)
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
