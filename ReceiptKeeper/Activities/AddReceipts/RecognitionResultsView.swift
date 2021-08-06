//
//  RecognitionResultsView.swift
//  RecognitionResultsView
//
//  Created by Andrei Chenchik on 6/8/21.
//

import SwiftUI

struct RecognitionResultsView: View {
    @EnvironmentObject var recognizer: Recognizer

    let index: Int

    var body: some View {
        if let image = recognizer.receiptScans[index].recognizedImage {
                List {
                    ForEach(recognizer.receiptScans[index].content) { line in
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
                }.navigationTitle(recognizer.receiptScans[index].title ?? "Receipt")
        } else {
            ProgressView()
                .onAppear {
                    recognizer.recognize(imageAt: index)
                }
        }
    }
}

//struct RecognitionResultsView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecognitionResultsView()
//    }
//}
