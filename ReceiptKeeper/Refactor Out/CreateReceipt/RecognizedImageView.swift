//
//  RecognizedImageView.swift
//  RecognizedImageView
//
//  Created by Andrei Chenchik on 18/8/21.
//

import SwiftUI

struct RecognizedImageView: View {
    @ObservedObject var receiptDraft: Draft
    
    var body: some View {
        ZStack {
            if let scanImage = receiptDraft.scanImage {
                Image(uiImage: scanImage)
                    .resizable()
                    .scaledToFit()
            }
            
            if let charBoxesLayer = receiptDraft.scanCharBoxesLayer {
                Image(uiImage: charBoxesLayer)
                    .resizable()
                    .scaledToFit()
            }
            
            if let textBoxesLayer = receiptDraft.scanTextBoxesLayer {
                Image(uiImage: textBoxesLayer)
                    .resizable()
                    .scaledToFit()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.vertical, 15)
    }
}

//struct RecognizedImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecognizedImageView()
//    }
//}
