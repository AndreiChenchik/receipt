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
        @Published var receiptDraft: Draft
        
        let dataController: DataController

        init(receiptDraft: Draft, dataController: DataController) {
            self.receiptDraft = receiptDraft
            self.dataController = dataController
        }

        func recognizeScan(_ cgImage: CGImage) -> (text: [VNRecognizedTextObservation], chars: [VNTextObservation])? {
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
                return (textObservations, charObservations)
            } else {
                return nil
            }
        }

        func recognize() async {
            guard let image = receiptDraft.scanImage, let cgImage = image.cgImage else { return }

            guard let (textObservations, charObservations) = recognizeScan(cgImage) else { return }

            let charBoundingBoxes: [CGRect] = charObservations.reduce([]) { partialResult, charObservation in
                let characterRects = charObservation.characterBoxes?.map { $0.boundingBox.imageRectFromNormalizedRect(with: image.size) } ?? []
                return partialResult + characterRects
            }
            async let imageCharsBoundingBoxes = image.getLayerWithRects(charBoundingBoxes, with: .green, using: .fill, opacity: 0.15)

            async let textBlocks = collectTextBlocks(from: textObservations, with: charBoundingBoxes, on: image.size)
            let receivedTextBlocks = await textBlocks
            async let draftLines = DraftLine.buildArray(from: composeLines(from: receivedTextBlocks))

            let textBoundingBoxes = receivedTextBlocks.map { $0.boundingBox }
            async let imageTextBoundingBoxes = image.getLayerWithRects(textBoundingBoxes, with: .blue, opacity: 0.4)

            let receivedDraftLines = await draftLines
            let receivedScanCharBoxesLayer = await imageCharsBoundingBoxes
            let receivedScanTextBoxesLayer = await imageTextBoundingBoxes

            DispatchQueue.main.async { [weak self] in
                self?.receiptDraft.draftLines = receivedDraftLines

                let totalLine = receivedDraftLines.first { $0.value != "" && $0.label.lowercased() == "total" }
                self?.receiptDraft.totalValue = totalLine?.value ?? ""
                self?.receiptDraft.storeTitle = receivedDraftLines.first?.label ?? "Receipt"
                self?.receiptDraft.transactionDate = DraftDateTime(from: receivedDraftLines.map { $0.label })

                self?.receiptDraft.scanTextBoxesLayer = receivedScanTextBoxesLayer
                self?.receiptDraft.scanCharBoxesLayer = receivedScanCharBoxesLayer
            }

        }

        private func collectTextBlocks(from textObservations: [VNRecognizedTextObservation], with charBoundingBoxes: [CGRect], on imageSize: CGSize) -> [RecognizedTextBlock] {
            let textBlocks: [RecognizedTextBlock] = textObservations.map { observation in
                let text = observation.topCandidates(1).first?.string ?? ""
                let boundingBox = observation.boundingBox.imageRectFromNormalizedRect(with: imageSize)
                let innerCharBoundingBoxes = boundingBox.filterInnerRects(from: charBoundingBoxes, with: 0.98)

                return RecognizedTextBlock(text: text, boundingBox: boundingBox, chars: innerCharBoundingBoxes)
            }

            return textBlocks
        }

        private func composeLines(from textBlocks: [RecognizedTextBlock]) -> [RecognizedTextLine] {
            let sortedTextBlocks = textBlocks.sorted { $0.boundingBox.minY < $1.boundingBox.minY }

            var composedLines = [RecognizedTextLine]()
            var currentLine = RecognizedTextLine()

            for block in sortedTextBlocks {
                if let newLine = RecognizedTextLine(from: currentLine, combinedWith: block) {
                    currentLine = newLine
                } else {
                    if let lastLine = composedLines.last {
                        if let newLine = RecognizedTextLine(from: currentLine, combinedWith: lastLine) {
                            currentLine = newLine
                            composedLines.removeLast()
                        }
                    }

                    composedLines.append(currentLine)
                    currentLine = RecognizedTextLine(textBlocks: [block])
                }
            }
            if !currentLine.textBlocks.isEmpty { composedLines.append(currentLine) }

            return composedLines
        }
    }
}
