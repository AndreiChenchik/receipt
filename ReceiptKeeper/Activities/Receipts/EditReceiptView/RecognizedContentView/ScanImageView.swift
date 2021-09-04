//
//  ScanImageView.swift
//  ScanImageView
//
//  Created by Andrei Chenchik on 25/8/21.
//

import SwiftUI

struct ScanImageView: View {
    @ObservedObject var receipt: Receipt

    @Environment(\.presentationMode) var presentationMode

    @State private var textBoundingBoxesLayer: UIImage? = nil
    @State private var charBoundingBoxesLayer: UIImage? = nil

    var dismissButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            if receipt.scanImageData != nil {
                //TODO: Add photo picker for devices without scan
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Dismiss")
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                if let scanImage = receipt.scanImage {
                    Image(uiImage: scanImage)
                        .resizable()
                        .scaledToFit()
                }

                if let textImage = textBoundingBoxesLayer {
                    Image(uiImage: textImage)
                        .resizable()
                        .scaledToFit()
                }

                if let charsImage = charBoundingBoxesLayer {
                    Image(uiImage: charsImage)
                        .resizable()
                        .scaledToFit()
                }
            }
            .padding(25)
            .animation(.default, value: charBoundingBoxesLayer)
            .animation(.default, value: textBoundingBoxesLayer)
            .onAppear(perform: drawLayers)
            .navigationTitle("Receipt scan")
            .toolbar {
                dismissButton
            }
        }
    }

    func drawLayers() {
        DispatchQueue.main.async {
            guard let scanImage = receipt.scanImage,
                  let recognizedContent = receipt.recognitionData?.content else { return }

            DispatchQueue.global(qos: .userInteractive).async {
                let textBoundingBoxesLayer = scanImage.getLayerWithRects(recognizedContent.allTextBoxes, with: .blue, opacity: 0.4)
                let charBoundingBoxesLayer = scanImage.getLayerWithRects(recognizedContent.allCharBoxes, with: .green, using: .fill, opacity: 0.15)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.textBoundingBoxesLayer = textBoundingBoxesLayer
                    self.charBoundingBoxesLayer = charBoundingBoxesLayer
                }
            }
        }
    }
}

//struct ScanImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        ScanImageView()
//    }
//}
