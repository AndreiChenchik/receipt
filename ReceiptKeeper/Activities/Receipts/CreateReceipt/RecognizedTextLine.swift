//
//  ObservedLine.swift
//  ObservedLine
//
//  Created by Andrei Chenchik on 6/8/21.
//

import Foundation
import Vision

struct RecognizedTextLine {
    var textBlocks = [RecognizedTextBlock]()
    var linkedLines = [RecognizedTextLine]()
}

extension RecognizedTextLine {
    var sortedTextBlocks: [RecognizedTextBlock] {
        textBlocks.sorted { $0.boundingBox.minX < $1.boundingBox.minX }
    }

    var sortedLinkedLines: [RecognizedTextLine] {
        linkedLines.sorted { $0.boundingBox.minY < $1.boundingBox.minY }
    }


    var label: String {
        guard !textBlocks.isEmpty else { return "" }

        var lineContents = sortedTextBlocks.map { $0.text }
        if value != nil { lineContents.removeLast() }

        if lineContents.isEmpty {
            let linkedContents = sortedLinkedLines.map { $0.label }

            return linkedContents.joined(separator: " ")
        } else {
            var label = lineContents.joined(separator: " ")

            for linkedLine in sortedLinkedLines {
                if linkedLine.boundingBox.minY < boundingBox.minY {
                    label = linkedLine.label + " " + label
                } else {
                    label = label + " " + linkedLine.label
                }
            }

            return label
        }
    }

    var value: Double? {
        let unnecessaryWords = ["usd", "eur", "$", "€"]

        if var lastText = sortedTextBlocks.last?.text {
            lastText = lastText.replacingOccurrences(of: ",", with: ".")
            let words = lastText.split(separator: " ").filter { !unnecessaryWords.contains($0.lowercased()) }
            lastText = words.joined(separator: " ")

            if lastText.contains(".") {
                return Double(lastText)
            }
        }

        return nil
    }
}

extension RecognizedTextLine {
    var boundingBox: CGRect {
        let rects = textBlocks.map { $0.boundingBox } + linkedLines.map { $0.boundingBox }
        let boundingBox = rects.reduce(CGRect.null) { $0.union($1) }

        return boundingBox
    }

    var chars: [CGRect] {
        textBlocks.reduce([]) { $0 + $1.chars }
    }

    var baseline: Baseline {
        Baseline(of: chars, withBounding: boundingBox)
    }
}

extension RecognizedTextLine {
    static let possibleOverlapRatio = 0.02
    static let possibleDistanceRatio = 0.5

    init?(from line: RecognizedTextLine, combinedWith additionalLine: RecognizedTextLine) {
        if line.textBlocks.isEmpty {
            self.textBlocks = additionalLine.textBlocks
            self.linkedLines = additionalLine.linkedLines
            return
        }

        if line.baseline ~~ additionalLine.baseline && line.doNotOverlap(with: additionalLine) {
            self.textBlocks = line.textBlocks + additionalLine.textBlocks
            self.linkedLines = line.linkedLines + additionalLine.linkedLines
            return
        }

        if line.isCloseEnough(with: additionalLine) {
            if line.value != nil && additionalLine.value == nil {
                self.textBlocks = line.textBlocks
                self.linkedLines = line.linkedLines + [additionalLine]
                return
            } else if line.value != nil && additionalLine.value == nil {
                self.textBlocks = additionalLine.textBlocks
                self.linkedLines = additionalLine.linkedLines + [line]
                return
            }
        }

        return nil
    }

    init?(from line: RecognizedTextLine, combinedWith textBlock: RecognizedTextBlock) {
        let textBlockLine = RecognizedTextLine(textBlocks: [textBlock])
        self.init(from: line, combinedWith: textBlockLine)
    }

    private func isCloseEnough(with otherLine: RecognizedTextLine) -> Bool {
        let upperLowerY = min(self.boundingBox.maxY, otherLine.boundingBox.maxY)
        let lowerUpperY = max(self.boundingBox.minY, otherLine.boundingBox.minY)

        let distance = lowerUpperY - upperLowerY
        let height = min(self.boundingBox.height, otherLine.boundingBox.height)

        let distanceRatio = distance / height
        return distanceRatio < Self.possibleDistanceRatio
    }

    private func doNotOverlap(with otherLine: RecognizedTextLine) -> Bool {
        let blocksCombinations = zip(self.textBlocks, otherLine.textBlocks)

        let overlapValue: CGFloat = blocksCombinations.reduce(0.0) { partialResult, pair in
            let lhsXRange = pair.0.boundingBox.minX...pair.0.boundingBox.maxX
            let rhsXRange = pair.1.boundingBox.minX...pair.1.boundingBox.maxX
            let intersection = lhsXRange.clamped(to: rhsXRange)

            return partialResult + intersection.upperBound - intersection.lowerBound
        }

        let overlapRatio = overlapValue / self.boundingBox.width

        return overlapRatio <= Self.possibleOverlapRatio
    }
}
