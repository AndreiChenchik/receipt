//
//  RecognizerViewModel.swift
//  RecognizerViewModel
//
//  Created by Andrei Chenchik on 8/8/21.
//

import Foundation
import Vision
import UIKit

extension RecognizerView {
    class ViewModel: ObservableObject {
        let receiptDraft: ReceiptDraft
        let dataController: DataController

        init(receiptDraft: ReceiptDraft, dataController: DataController) {
            self.receiptDraft = receiptDraft
            self.dataController = dataController
        }

        @Published var recognizedImage: UIImage? = nil
        @Published var recognizedContents = [ReceiptLine]()
        @Published var recognizedTitle: String = "Receipt"

        func recognizeDraft() {
            let image = receiptDraft.scanImage
            let recognizeTextRequest = VNRecognizeTextRequest { [weak self] request, error in
                guard let self = self else { return }
                guard var results = request.results as? [VNRecognizedTextObservation] else { return }
                guard !results.isEmpty else { return }

                results.sort { $0.boundingBox.minY > $1.boundingBox.minY }

                var lines = [ReceiptLine]()
                var line = ReceiptLine(maxY: results[0].boundingBox.maxY, minY: results[0].boundingBox.minY)

                for result in results {
                    if line.canContain(result) {
                        line.addObservation(result)
                    } else {
                        lines.append(line)
                        line = ReceiptLine(maxY: result.boundingBox.maxY, minY: result.boundingBox.minY, observations: [result])
                    }
                }
                lines.append(line)

                lines = self.mergeLines(lines)
                lines = self.filterBeforeTotal(lines)

                let recognizedImage = self.renderBoundingBoxes(on: image, using: results)

                DispatchQueue.main.async {
                    self.recognizedImage = recognizedImage
                    self.recognizedContents = lines
                    self.recognizedTitle = lines[0].label
                }
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

        func renderBoundingBoxes(on image: UIImage, using recognitionResults: [VNRecognizedTextObservation]) -> UIImage {
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: image.size.width, height: image.size.height))
            let imageWithBoundingBoxes = renderer.image { context in
                image.draw(at: CGPoint(x: 0, y: 0))

                context.cgContext.setStrokeColor(UIColor.blue.cgColor)
                context.cgContext.setLineWidth(3)

                var boundingBoxes = [CGRect]()
                for result in recognitionResults {
                    let scaledBox = VNImageRectForNormalizedRect(result.boundingBox, Int(image.size.width), Int(image.size.height))
                    let cgTransform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -image.size.height)
                    boundingBoxes.append(scaledBox.applying(cgTransform))
                }

                context.cgContext.addRects(boundingBoxes)
                context.cgContext.drawPath(using: .stroke)
            }

            return imageWithBoundingBoxes
        }

        func mergeLines(_ lines: [ReceiptLine]) -> [ReceiptLine] {
            guard lines.count > 1 else { return lines }

            var updatedLines = [ReceiptLine]()
            var previousLine = lines[0]

            for line in lines {
                if (line.value == nil) != (previousLine.value == nil) && previousLine.isYCloseForMerge(line) {
                    print("merging \(previousLine.text) with \(line.text)")
                    previousLine.addObservations(line.observations)
                } else {
                    updatedLines.append(previousLine)
                    previousLine = line
                }
            }

            return updatedLines
        }

        func filterBeforeTotal(_ lines: [ReceiptLine]) -> [ReceiptLine] {
            var updatedLines = [ReceiptLine]()

            for line in lines {
                updatedLines.append(line)
                if line.label.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "total" { break }
            }

            return updatedLines
        }
    }
}
