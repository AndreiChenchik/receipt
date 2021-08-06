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
                ForEach(recognizer.receiptScans) { scan in
                    let image = scan.scanImage
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                }
            }

//            Text("Scanned \(recognizer.receiptScans.count) pages")
//                .padding()

            //            Button {
            //                recognizer.recognize()
            //            } label: {
            //                Label("Recognize", systemImage: "doc.text.viewfinder")
            //                    .foregroundColor(.white)
            //                    .padding()
            //                    .frame(maxWidth: .infinity)
            //                    .background(Color.blue)
            //                    .clipShape(Capsule())
            //            }
            //            .padding()

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
