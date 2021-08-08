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
        if let image = viewModel.recognizedImage {
                List {
                    ForEach(viewModel.recognizedContents) { line in
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
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                }.navigationTitle(viewModel.recognizedTitle)
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
