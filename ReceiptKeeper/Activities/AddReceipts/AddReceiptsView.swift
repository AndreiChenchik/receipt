//
//  AddReceiptsView.swift
//  AddReceiptsView
//
//  Created by Andrei Chenchik on 6/8/21.
//

import SwiftUI

struct AddReceiptsView: View {
    let recognizer = Recognizer()

    @State private var isFinishedPicking = false

    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(isActive: $isFinishedPicking) {
                    NewReceiptsView()
                } label: {
                    EmptyView()
                }

                ScanPickerView(isFinishedPicking: $isFinishedPicking)
                    .ignoresSafeArea()
            }
            .navigationTitle("Scan & Edit")
            .navigationBarHidden(true)
        }
        .environmentObject(recognizer)

    }
}

struct AddReceiptsView_Previews: PreviewProvider {
    static var previews: some View {
        AddReceiptsView()
    }
}
