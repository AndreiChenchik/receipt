//
//  Recognizer.swift
//  Recognizer
//
//  Created by Andrei Chenchik on 6/8/21.
//

import Foundation
import Vision
import UIKit

class Recognizer: ObservableObject {
    @Published private(set) var receiptScans = [ReceiptScan]()

    func setScans(_ scans: [UIImage]) {
        for index in 0..<scans.count {
            let receiptScan = ReceiptScan(scanImage: scans[index])

            if index >= receiptScans.count {
                receiptScans.append(receiptScan)
            } else if scans[index] != receiptScans[index].scanImage {
                receiptScans[index] = receiptScan
            }
        }
    }

    func recognize(imageAt index: Int) {
        let image = receiptScans[index].scanImage
        let recognizeTextRequest = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self else { return }
            guard var results = request.results as? [VNRecognizedTextObservation] else { return }

            results.sort { $0.boundingBox.midY > $1.boundingBox.midY }


            let renderer = UIGraphicsImageRenderer(size: CGSize(width: image.size.width, height: image.size.height))
            let recognizedImage = renderer.image { context in
                image.draw(at: CGPoint(x: 0, y: 0))

                context.cgContext.setStrokeColor(UIColor.blue.cgColor)
                context.cgContext.setLineWidth(3)

                var boundingBoxes = [CGRect]()
                for result in results {
                    let scaledBox = VNImageRectForNormalizedRect(result.boundingBox, Int(image.size.width), Int(image.size.height))
                    let cgTransform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -image.size.height)
                    boundingBoxes.append(scaledBox.applying(cgTransform))
                }

                context.cgContext.addRects(boundingBoxes)
                context.cgContext.drawPath(using: .stroke)
            }

            DispatchQueue.main.async {
                self.receiptScans[index].recognizedImage = recognizedImage
            }

            //            for result in results {
            //                guard let candidate = result.topCandidates(1).first else { continue }
            //                print(candidate.string)
            //            }
        }

        recognizeTextRequest.recognitionLevel = .accurate
        recognizeTextRequest.usesLanguageCorrection = true

        guard let cgImage = image.cgImage else { return }
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try imageRequestHandler.perform([recognizeTextRequest])
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}

