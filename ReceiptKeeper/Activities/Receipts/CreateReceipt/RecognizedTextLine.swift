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

        let lineContents = sortedTextBlocks.map { $0.text }
        var label = lineContents.joined(separator: " ")

        for linkedLine in sortedLinkedLines {
            if linkedLine.boundingBox.maxY < boundingBox.maxY {
                label = linkedLine.label + " " + label
            } else {
                label = label + " " + linkedLine.label
            }
        }

        return label
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
    init?(from line: RecognizedTextLine, combinedWith additionalLine: RecognizedTextLine) {
        if line.baseline ~~ additionalLine.baseline {
            self.textBlocks = line.textBlocks + additionalLine.textBlocks
            self.linkedLines = line.linkedLines + additionalLine.linkedLines
            return
        }

        print("\(line.label) if not the same line as \(additionalLine.label)" )

        return nil
    }

    init?(from line: RecognizedTextLine, combinedWith textBlock: RecognizedTextBlock) {
        let textBlockLine = RecognizedTextLine(textBlocks: [textBlock])
        self.init(from: line, combinedWith: textBlockLine)
    }

    func isLinkedWith(_ line: RecognizedTextLine) -> Bool {
        return false
    }
}
