//
//  RecognizedContent.swift
//  RecognizedContent
//
//  Created by Andrei Chenchik on 23/8/21.
//

import CoreGraphics

struct RecognizedContent: Codable {
    let lines: [Line]
    let allCharBoxes: [CGRect]
    let allTextBoxes: [CGRect]

    init(lines: [Line] = [], allCharBoxes: [CGRect] = [], allTextBoxes: [CGRect] = []) {
        self.lines = lines
        self.allCharBoxes = allCharBoxes
        self.allTextBoxes = allTextBoxes
    }

    init(from recognizedObservations: RecognizedObservations, imageSize: CGSize) {
        let charBoundingBoxes = Self.extractBoundingBoxes(from: recognizedObservations, with: imageSize)


        let allLines: [Line] = recognizedObservations.textObservations.compactMap { textObservation in
            guard let text = textObservation.topCandidates(1).first?.string else { return nil }

            let boundingBox = textObservation.boundingBox.imageRectFromNormalizedRect(with: imageSize)
            let chars = boundingBox.filterInnerRects(from: charBoundingBoxes, with: 0.98)

            return Line(text: text, boundingBox: boundingBox, chars: chars)
        }

        let reducedLines = Self.reduceLines(allLines)
        let lines = Self.classifyLines(reducedLines)

        self.lines = lines
        self.allCharBoxes = charBoundingBoxes
        self.allTextBoxes = allLines.map { $0.boundingBox }
    }

    static func extractBoundingBoxes(from recognizedObservations: RecognizedObservations, with imageSize: CGSize) -> [CGRect] {
        let boundingBoxes: [CGRect] = recognizedObservations.charObservations.reduce([]) { partialResult, charObservation in
            if let characterBoxes = charObservation.characterBoxes {
                let characterRects = characterBoxes.map { char in
                    char.boundingBox.imageRectFromNormalizedRect(with: imageSize)
                }

                return partialResult + characterRects
            } else {
                return partialResult
            }
        }

        return boundingBoxes
    }

    static func reduceLines(_ allLines: [Line]) -> [Line] {
        var reducedLines = [Line]()
        var currentLine = Line()

        for line in allLines {
            if let newLine = Line(from: currentLine, combinedWith: line) {
                currentLine = newLine
            } else {
                if let lastLine = reducedLines.last {
                    if let newLine = Line(from: currentLine, combinedWith: lastLine) {
                        currentLine = newLine
                        reducedLines.removeLast()
                    }
                }

                reducedLines.append(currentLine)
                currentLine = line
            }
        }
        if !currentLine.textBlocks.isEmpty { reducedLines.append(currentLine) }

        return reducedLines
    }

    static func classifyLines(_ lines: [Line]) -> [Line] {
        var classifiedLines = [Line]()
        var isTotalReached = false

        for line in lines {
            if line.label.lowercased().contains("total") {
                let newLine = Line(textBlocks: line.textBlocks, linkedLines: line.linkedLines, lineType: .total)
                isTotalReached = true
                classifiedLines.append(newLine)
            } else if line.value != nil && !isTotalReached {
                let newLine = Line(textBlocks: line.textBlocks, linkedLines: line.linkedLines, lineType: .item)
                classifiedLines.append(newLine)
            } else {
                classifiedLines.append(line)
            }
        }

        return classifiedLines
    }
}
