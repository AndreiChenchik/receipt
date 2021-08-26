//
//  Line.swift
//  Line
//
//  Created by Andrei Chenchik on 6/8/21.
//

import Foundation
import CoreGraphics
import SwiftUI

extension RecognizedContent {
    struct Line: Codable, Identifiable {
        enum ContentType: Codable {
            case unknown, date, address, total, item, venue
        }

        let id: UUID
        let textBlocks: [TextBlock]
        let linkedLines: [Self]
        let contentType: ContentType

        init(id: UUID = UUID(), textBlocks: [TextBlock] = [], linkedLines: [Self] = [], contentType: ContentType = .unknown) {
            self.id = id
            self.textBlocks = textBlocks
            self.linkedLines = linkedLines
            self.contentType = contentType
        }
    }
}

extension RecognizedContent.Line {
    init(text: String, boundingBox: CGRect, chars: [CGRect]) {
        self.id = UUID()
        self.linkedLines = [Self]()
        self.contentType = .unknown

        let textBlock = TextBlock(text: text, boundingBox: boundingBox, chars: chars)
        self.textBlocks = [textBlock]
    }

    var sortedTextBlocks: [TextBlock] {
        textBlocks.sorted { $0.boundingBox.minX < $1.boundingBox.minX }
    }

    var sortedLinkedLines: [Self] {
        linkedLines.sorted { $0.boundingBox.minY < $1.boundingBox.minY }
    }

    var text: String {
        if let valueString = valueString {
            if label.isEmpty {
                return valueString
            } else {
                return label + "\n" + valueString
            }
        } else {
            return label
        }
    }

    var valueString: String? {
        if let value = value {
            return String(format: "%.2f", value)
        } else {
            return nil
        }
    }

    var label: String {
        guard !textBlocks.isEmpty else { return "" }

        var lineContents = sortedTextBlocks.map { $0.text }
        if value != nil { lineContents.removeLast() }

        if lineContents.isEmpty {
            let linkedContents = sortedLinkedLines.map { $0.label }

            return linkedContents.joined(separator: "\n")
        } else {
            var label = lineContents.joined(separator: "\n")

            for linkedLine in sortedLinkedLines {
                if linkedLine.boundingBox.minY < boundingBox.minY {
                    label = linkedLine.label + "\n" + label
                } else {
                    label = label + "\n" + linkedLine.label
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

extension RecognizedContent.Line {
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

extension RecognizedContent.Line {
    static let possibleXOverlapRatio = 0.02
    static let possibleYDistanceRatio = 0.5

    init?(from line: Self, combinedWith additionalLine: Self) {
        if line.textBlocks.isEmpty {
            self.id = additionalLine.id
            self.contentType = additionalLine.contentType
            self.textBlocks = additionalLine.textBlocks
            self.linkedLines = additionalLine.linkedLines
            return
        }

        if line.baseline ~~ additionalLine.baseline && line.doNotOverlap(with: additionalLine) {
            self.id = line.id
            self.contentType = line.contentType
            self.textBlocks = line.textBlocks + additionalLine.textBlocks
            self.linkedLines = line.linkedLines + additionalLine.linkedLines
            return
        }

        return nil
    }

    init?(from line: Self, linkedWith additionalLine: Self) {
        if line.isCloseEnough(with: additionalLine) {
            if line.value != nil && additionalLine.value == nil {
                self.id = line.id
                self.contentType = line.contentType
                self.textBlocks = line.textBlocks
                self.linkedLines = line.linkedLines + [additionalLine]
                return
            } else if line.value == nil && additionalLine.value != nil {
                self.id = additionalLine.id
                self.contentType = additionalLine.contentType
                self.textBlocks = additionalLine.textBlocks
                self.linkedLines = additionalLine.linkedLines + [line]
                return
            }
        }

        return nil
    }

    private func isCloseEnough(with otherLine: Self) -> Bool {
        let upperLowerY = min(self.boundingBox.maxY, otherLine.boundingBox.maxY)
        let lowerUpperY = max(self.boundingBox.minY, otherLine.boundingBox.minY)

        let yDistance = lowerUpperY - upperLowerY
        let height = min(self.boundingBox.height, otherLine.boundingBox.height)

        let yDistanceRatio = yDistance / height
        return yDistanceRatio < Self.possibleYDistanceRatio
    }

    private func doNotOverlap(with otherLine: Self) -> Bool {
        let blocksCombinations = zip(self.textBlocks, otherLine.textBlocks)

        let yOverlapValue: CGFloat = blocksCombinations.reduce(0.0) { partialResult, pair in
            let lhsXRange = pair.0.boundingBox.minX...pair.0.boundingBox.maxX
            let rhsXRange = pair.1.boundingBox.minX...pair.1.boundingBox.maxX
            let intersection = lhsXRange.clamped(to: rhsXRange)

            return partialResult + intersection.upperBound - intersection.lowerBound
        }

        let yOverlapRatio = yOverlapValue / self.boundingBox.width

        return yOverlapRatio <= Self.possibleXOverlapRatio
    }
}

extension RecognizedContent.Line {
    static var exclusiveContentTypes: [ContentType] = [.venue, .total, .date]

    func withChangedContentType(to contentType: ContentType) -> Self {
        Self(id: self.id, textBlocks: self.textBlocks, linkedLines: self.linkedLines, contentType: contentType)
    }
}
