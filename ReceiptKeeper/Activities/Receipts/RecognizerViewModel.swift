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

        @Published var receiptContents = [RecognizedLine]()
        @Published var receiptTitle: String = "Receipt"
        @Published var isRecognitionDone = false

        @Published var imageLayerWithTextBoundingBoxes = UIImage()
        @Published var imageLayerWithCharsBoundingBoxes = UIImage()

        var enabledLines: [RecognizedLine] {
            receiptContents.filter { $0.enabled }
        }

        func recognizeDraft() {
            guard let cgImage = receiptDraft.scanImage.cgImage else { return }

            let recognitionGroup = DispatchGroup()

            recognitionGroup.enter()
            DispatchQueue.global(qos: .userInitiated).async {
                self.recognizeText(from: cgImage)
                recognitionGroup.leave()
            }

            recognitionGroup.enter()
            DispatchQueue.global(qos: .userInitiated).async {
                self.locateAllChars(from: cgImage)
                recognitionGroup.leave()
            }

            recognitionGroup.notify(queue: .global(qos: .userInitiated)) {
                self.buildContent()
            }
        }

        private let boundingBoxIntersectionThreshold = 0.98
        private let xOverlapThreshold = 0.02
        private let midYOffsetThreshold = 0.6

        private var allTextObservations = [VNRecognizedTextObservation]()
        private var allCharsOnDraft = [CGRect]()

        private func buildContent() {
            var receiptLines = [RecognizedLine]()
            var imageTextBoundingBoxes = UIImage()
            var imageCharsBoundingBoxes = UIImage()

            let buildGroup = DispatchGroup()

            buildGroup.enter()
            DispatchQueue.global(qos: .userInitiated).async {
                receiptLines = self.getReceiptLines()
                buildGroup.leave()
            }

            buildGroup.enter()
            DispatchQueue.global(qos: .userInitiated).async {
                let image = self.receiptDraft.scanImage
                let boundingBoxes = self.allTextObservations.map { self.cgRectFromNormalizedRect($0.boundingBox, for: image.size) }

                imageTextBoundingBoxes = image.getLayerWithRects(boundingBoxes, using: .blue)

                buildGroup.leave()
            }

            buildGroup.enter()
            DispatchQueue.global(qos: .userInitiated).async {
                let image = self.receiptDraft.scanImage
                let boundingBoxes = self.allCharsOnDraft.map { self.cgRectFromNormalizedRect($0, for: image.size) }

                imageCharsBoundingBoxes = image.getLayerWithRects(boundingBoxes, using: .green)
                buildGroup.leave()
            }

            buildGroup.notify(queue: .main) {
                self.imageLayerWithTextBoundingBoxes = imageTextBoundingBoxes
                self.imageLayerWithCharsBoundingBoxes = imageCharsBoundingBoxes
                self.receiptContents = receiptLines
                self.receiptTitle = receiptLines[0].label
                self.isRecognitionDone = true
            }
        }

        private func getReceiptLines() -> [RecognizedLine] {
            guard !allTextObservations.isEmpty else { return [] }

            let sortedObservations = allTextObservations.sorted { $0.boundingBox.minY > $1.boundingBox.minY }

            var lines = [RecognizedLine()]
            var totalReached = false
            var i = 0

            for observation in sortedObservations {
                if self.hasSameBaseline(observation, in: lines[i]) {
                    lines[i].observations.append(observation)
                } else {
                    if i > 1, let updatedLine = mergeTwoLines(lines[i-1...i]) {
                        lines[i-1] = updatedLine
                        lines[i] = RecognizedLine()
                    } else {
                        i += 1
                        lines.append(RecognizedLine())
                    }

                    if i > 1, !totalReached, lines[i-1].value != nil {
                        lines[i-1].enabled = true

                        if lines[i-1].label.lowercased() == "total" {
                            totalReached = true
                        }
                    }

                    lines[i].observations.append(observation)
                }
            }

            if i > 1, let updatedLine = mergeTwoLines(lines[i-1...i]) {
                lines[i-1] = updatedLine
                lines = lines.dropLast()
            }

            if lines[i].value != nil {
                lines[i].enabled = true
            }

            return lines
        }

        private func recognizeText(from cgImage: CGImage) {
            let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            let recognizeTextRequest = VNRecognizeTextRequest { [weak self] request, error in
                guard let self = self else { return }

                guard let results = request.results as? [VNRecognizedTextObservation] else { return }
                self.allTextObservations = results
            }

            recognizeTextRequest.recognitionLevel = .accurate
            recognizeTextRequest.usesLanguageCorrection = true

            do {
                try imageRequestHandler.perform([recognizeTextRequest])
            } catch let error {
                print(error.localizedDescription)
            }
        }

        private func locateAllChars(from cgImage: CGImage) {
            let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            let recognizeCharsRequest = VNDetectTextRectanglesRequest { [weak self] request, error in
                guard let self = self else { return }
                guard let results = request.results as? [VNTextObservation] else { return }

                let charsObservations = results.reduce([CGRect]()) { partialResult, textObservation in
                    guard let characterBoxes = textObservation.characterBoxes else {
                        return partialResult
                    }

                    return partialResult + characterBoxes.map { $0.boundingBox }
                }

                self.allCharsOnDraft = charsObservations
            }

            recognizeCharsRequest.reportCharacterBoxes = true

            do {
                try imageRequestHandler.perform([recognizeCharsRequest])
            } catch let error {
                print(error.localizedDescription)
            }
        }

        private func cgRectFromNormalizedRect(_ rect: CGRect, for size: CGSize) -> CGRect {
            let scaledBox = VNImageRectForNormalizedRect(rect, Int(size.width), Int(size.height))
            let cgTransform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -size.height)

            return scaledBox.applying(cgTransform)
        }

        private func mergeTwoLines(_ lines: ArraySlice<RecognizedLine>) -> RecognizedLine? {
            guard lines.count == 2 else { return nil }

            var firstLine = lines.first!
            var secondLine = lines.last!

            if (firstLine.value == nil) != (secondLine.value == nil) && isYCloseForMerge(firstLine, secondLine) {
                if firstLine.value != nil {
                    firstLine.additionalLines.append(secondLine)
                    return firstLine
                } else {
                    secondLine.additionalLines.append(firstLine)
                    return secondLine
                }
            } else {
                return nil
            }
        }

        private func hasSameBaseline(_ observation: VNRecognizedTextObservation, in line: RecognizedLine) -> Bool {
            let observationChars = observation.boundingBox.filterInnerRects(from: allCharsOnDraft, with: boundingBoxIntersectionThreshold)
            let observationBaseline = Baseline(of: observationChars)

            let lineChars = line.boundingBox.filterInnerRects(from: allCharsOnDraft, with: boundingBoxIntersectionThreshold)
            let lineBaseline = Baseline(of: lineChars)

            return lineBaseline ~~ observationBaseline
        }

        private func isYCloseForMerge(_ firstLine: RecognizedLine, _ secondLine: RecognizedLine) -> Bool {
            firstLine.boundingBox.minY - secondLine.boundingBox.maxY < min(secondLine.boundingBox.height, firstLine.boundingBox.height) / 2
        }
    }
}
