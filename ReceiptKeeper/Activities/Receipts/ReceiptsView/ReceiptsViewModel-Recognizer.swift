//
//  ReceiptsViewModel-Recognizer.swift
//  ReceiptsViewModel-Recognizer
//
//  Created by Andrei Chenchik on 24/8/21.
//

import Vision
import UIKit

extension ReceiptsView.ViewModel {
    func processNewScans() {
        for image in newScanImages.reversed() {
            dataController.createReceipt(with: image) { receiptID in
                self.recognizeContent(from: image) { recognizedContent in
                    self.dataController.updateReceipt(withID: receiptID, from: recognizedContent)
                }
            }
        }

        newScanImages = []
    }

    func recognizeContent(from scanImage: UIImage, _ completionHandler: @escaping (RecognizedContent?) -> Void) {
        if let image = scanImage.cgImage,
           let observations = extractObservations(from: image) {
            let recognizedContent = RecognizedContent(from: observations, imageSize: scanImage.size)

            completionHandler(recognizedContent)
        } else {
            completionHandler(nil)
        }
    }

    func extractObservations(from cgImage: CGImage) -> RecognizedObservations? {
        var textObservations: [VNRecognizedTextObservation]? = nil
        var charObservations: [VNTextObservation]? = nil

        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        let recognizeTextRequest = VNRecognizeTextRequest { request, _ in
            textObservations = request.results as? [VNRecognizedTextObservation]
        }
        recognizeTextRequest.recognitionLevel = .accurate
        recognizeTextRequest.usesLanguageCorrection = true

        let recognizeCharsRequest = VNDetectTextRectanglesRequest { request, _ in
            charObservations = request.results as? [VNTextObservation]
        }
        recognizeCharsRequest.reportCharacterBoxes = true

        do {
            try imageRequestHandler.perform([recognizeTextRequest, recognizeCharsRequest])
        } catch let error {
            print(error.localizedDescription)
        }

        if let textObservations = textObservations, let charObservations = charObservations {
            return RecognizedObservations(textObservations: textObservations, charObservations: charObservations)
        } else {
            return nil
        }
    }
}
