//
//  RecognizerView.swift
//  RecognizerView
//
//  Created by Andrei Chenchik on 8/8/21.
//

import SwiftUI

struct RecognizerView: View {
    @StateObject var viewModel: ViewModel

    init(receiptDraft: ReceiptDraft, dataController: DataController) {
        let viewModel = ViewModel(receiptDraft: receiptDraft, dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        if viewModel.isRecognitionDone {
                List {
                    ForEach(viewModel.enabledLines) { line in
                        if let value = line.value {
                            HStack {
                                Text(line.label)
                                    .font(.subheadline)
                                Spacer()
                                Text(String(format: "%g", value))
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    ZStack {
                        Image(uiImage: viewModel.receiptDraft.scanImage)
                            .resizable()
                            .scaledToFit()
                        Image(uiImage: viewModel.imageCharsBoundingBoxes!)
                            .resizable()
                            .scaledToFit()
                        Image(uiImage: viewModel.imageTextBoundingBoxes!)
                            .resizable()
                            .scaledToFit()
                    }
                    .padding(10)

                }.navigationTitle(viewModel.receiptTitle)
        } else {
            ProgressView()
                .onAppear(perform: viewModel.recognizeDraft)
        }
    }
}

//struct RecognizerView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecognizerView()
//    }
//}
