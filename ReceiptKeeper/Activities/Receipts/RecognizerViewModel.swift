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

        @Published var imageTextBoundingBoxes: UIImage? = nil
        @Published var imageCharsBoundingBoxes: UIImage? = nil
        @Published var receiptContents = [RecognizedLine]()
        @Published var receiptTitle: String = "Receipt"
        @Published var isRecognitionDone = false

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

        private var textObservations = [VNRecognizedTextObservation]()
        private var charsObservations = [VNRectangleObservation]()

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
                imageTextBoundingBoxes = self.boundingBoxesImage(with: self.receiptDraft.scanImage.size, using: self.textObservations, color: .blue)
                buildGroup.leave()
            }

            buildGroup.enter()
            DispatchQueue.global(qos: .userInitiated).async {
                imageCharsBoundingBoxes = self.boundingBoxesImage(with: self.receiptDraft.scanImage.size, using: self.charsObservations, color: .green)
                buildGroup.leave()
            }

            buildGroup.notify(queue: .main) {
                self.imageTextBoundingBoxes = imageTextBoundingBoxes
                self.imageCharsBoundingBoxes = imageCharsBoundingBoxes
                self.receiptContents = receiptLines
                self.receiptTitle = receiptLines[0].label
                self.isRecognitionDone = true
            }
        }

        private func getReceiptLines() -> [RecognizedLine] {
            guard !textObservations.isEmpty else { return [] }

            let sortedObservations = textObservations.sorted { $0.boundingBox.minY > $1.boundingBox.minY }

            var lines = [RecognizedLine()]
            var totalReached = false
            var i = 0

            for observation in sortedObservations {
                if self.isTheSameLine(observation, in: lines[i]) {
                    lines[i].observations.append(observation)
                    lines[i].characters = filteredChars(for: lines[i].boundingBox)
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
                    lines[i].characters = filteredChars(for: lines[i].boundingBox)
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

        private func linearRegression(_ points: [CGPoint]) -> (CGFloat) -> CGFloat {
            let xs = points.map { $0.x }
            let ys = points.map { $0.y }

            let sum1 = average(multiply(ys, xs)) - average(xs) * average(ys)
            let sum2 = average(multiply(xs, xs)) - pow(average(xs), 2)
            let slope = sum1 / sum2
            let intercept = average(ys) - slope * average(xs)

            return { x in
                return slope * x + intercept
            }
        }

        private func multiply(_ a: [CGFloat], _ b: [CGFloat]) -> [CGFloat] {
            return zip(a, b).map(*)
        }

        private func average(_ input: [CGFloat]) -> CGFloat {
            return input.reduce(0, +) / CGFloat(input.count)
        }

        private func filteredChars(for boundingBox: CGRect) -> [VNRectangleObservation] {
            var filteredChars = [VNRectangleObservation]()

            for char in charsObservations {
                let intersectionArea = char.boundingBox.intersection(boundingBox).area
                let intersectionRatio = intersectionArea / char.boundingBox.area

                if intersectionRatio > boundingBoxIntersectionThreshold {
                    filteredChars.append(char)
                }
            }

//            let averageHeight = average(filteredChars.map { $0.boundingBox.height })
//            return filteredChars.filter { $0.boundingBox.height > 0.8 * averageHeight }
            return filteredChars
        }

        private func recognizeText(from cgImage: CGImage) {
            let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            let recognizeTextRequest = VNRecognizeTextRequest { [weak self] request, error in
                guard let self = self else { return }

                guard let results = request.results as? [VNRecognizedTextObservation] else { return }
                self.textObservations = results
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

                let charsObservations = results.reduce([VNRectangleObservation]()) { partialResult, textObservation in
                    guard let characterBoxes = textObservation.characterBoxes else {
                        return partialResult
                    }

                    return partialResult + characterBoxes
                }

                self.charsObservations = charsObservations
            }

            recognizeCharsRequest.reportCharacterBoxes = true

            do {
                try imageRequestHandler.perform([recognizeCharsRequest])
            } catch let error {
                print(error.localizedDescription)
            }
        }

        private func boundingBoxesImage(with canvasSize: CGSize, using observations: [VNRectangleObservation], color: UIColor = .red) -> UIImage {
            let renderer = UIGraphicsImageRenderer(size: canvasSize)
            let imageWithBoundingBoxes = renderer.image { context in
                context.cgContext.setStrokeColor(color.cgColor)
                context.cgContext.setLineWidth(3)

                var boundingBoxes = [CGRect]()
                for observation in observations {
                    let scaledBox = VNImageRectForNormalizedRect(observation.boundingBox, Int(canvasSize.width), Int(canvasSize.height))
                    let cgTransform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -canvasSize.height)
                    boundingBoxes.append(scaledBox.applying(cgTransform))
                }

                context.cgContext.addRects(boundingBoxes)
                context.cgContext.drawPath(using: .stroke)
            }

            return imageWithBoundingBoxes
        }

        private func boundingBoxesImage(with canvasSize: CGSize, using observations: [VNRecognizedTextObservation], color: UIColor = .red) -> UIImage {
            let renderer = UIGraphicsImageRenderer(size: canvasSize)
            let imageWithBoundingBoxes = renderer.image { context in
                context.cgContext.setStrokeColor(color.cgColor)
                context.cgContext.setLineWidth(3)

                var boundingBoxes = [CGRect]()
                for observation in observations {
                    let scaledBox = VNImageRectForNormalizedRect(observation.boundingBox, Int(canvasSize.width), Int(canvasSize.height))
                    let cgTransform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -canvasSize.height)
                    boundingBoxes.append(scaledBox.applying(cgTransform))

                    let midLine = linearRegression(filteredChars(for: observation.boundingBox).map { $0.boundingBox.lowerMid })
                    var lineStart = CGPoint(x: 0, y: midLine(0))
                    lineStart = VNImagePointForNormalizedPoint(lineStart, Int(canvasSize.width), Int(canvasSize.height)).applying(cgTransform)
                    var lineEnd = CGPoint(x: 1, y: midLine(1))
                    lineEnd = VNImagePointForNormalizedPoint(lineEnd, Int(canvasSize.width), Int(canvasSize.height)).applying(cgTransform)

                    context.cgContext.move(to: lineStart)
                    context.cgContext.addLine(to: lineEnd)
                    context.cgContext.drawPath(using: .stroke)
                }

                context.cgContext.addRects(boundingBoxes)
                context.cgContext.drawPath(using: .stroke)
            }

            return imageWithBoundingBoxes
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

        private func isTheSameLine(_ observation: VNRecognizedTextObservation, in line: RecognizedLine) -> Bool {
            if isInLine(observation, with: line) && isNoXOverlap(of: observation, with: line) {
                return true
            } else {
                return false
            }
        }

        private func isNoXOverlap(of observation: VNRecognizedTextObservation, with line: RecognizedLine) -> Bool {
            let targetWidth = observation.boundingBox.width
            let targetWidthRange = observation.boundingBox.minX...observation.boundingBox.maxX

            var xOverlap: CGFloat = 0
            for observation in line.observations {
                let observationWidthRange = observation.boundingBox.minX...observation.boundingBox.maxX
                let intersection = targetWidthRange.clamped(to: observationWidthRange)
                let intersectionLength = intersection.upperBound - intersection.lowerBound
                xOverlap += intersectionLength
            }

            let overlappedPortion = xOverlap / targetWidth
            return overlappedPortion < xOverlapThreshold
        }

        private func isInLine(_ observation: VNRecognizedTextObservation, with line: RecognizedLine) -> Bool {
            let midLine = linearRegression(line.characters.map { $0.boundingBox.lowerMid })
            let expectedMinY = midLine(observation.boundingBox.midX)
            let midYOffsetHeightRatio = abs(expectedMinY - observation.boundingBox.minY) / observation.boundingBox.height

            return midYOffsetHeightRatio < midYOffsetThreshold
        }

        private func isYCloseForMerge(_ firstLine: RecognizedLine, _ secondLine: RecognizedLine) -> Bool {
            firstLine.boundingBox.minY - secondLine.boundingBox.maxY < min(secondLine.boundingBox.height, firstLine.boundingBox.height) / 2
        }
    }
}
