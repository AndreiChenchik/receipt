//
//  RecognizedContent.swift
//  RecognizedContent
//
//  Created by Andrei Chenchik on 23/8/21.
//

import Foundation
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

        let sortedTextObservations = recognizedObservations.textObservations.sorted { $0.boundingBox.maxY > $1.boundingBox.maxY }

        let allLines: [Line] = sortedTextObservations.compactMap { textObservation in
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
                    if let newLine = Line(from: currentLine, linkedWith: lastLine) {
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
        var isVenueFound = false
        var isDateFound = false

        for line in lines {
            var contentType: Line.ContentType? = nil

            if !line.label.isEmpty && !isVenueFound {
                contentType = .venue
                isVenueFound = true
            } else if line.label.lowercased().contains("total") && line.value != nil && !isTotalReached {
                contentType = .total
                isTotalReached = true
            } else if !isDateFound && Self.getDateTime(from: line.text.replacingOccurrences(of: "\n", with: " ")) != nil {
                contentType = .date
                isDateFound = true
            } else if line.value != nil && !isTotalReached {
                contentType = .item
            }

            if let contentType = contentType {
                let newline = Line(textBlocks: line.textBlocks, linkedLines: line.linkedLines, contentType: contentType)
                classifiedLines.append(newline)
            } else {
                classifiedLines.append(line)
            }
        }

        return classifiedLines
    }

    func withChangedLineContentType(for line: Line, to contentType: Line.ContentType) -> Self? {
        if let lineIndexToModify = lines.firstIndex(where: { $0.id == line.id }) {
            var lines = self.lines
            lines[lineIndexToModify] = lines[lineIndexToModify].withChangedContentType(to: contentType)

            return RecognizedContent(lines: lines, allCharBoxes: allCharBoxes, allTextBoxes: allTextBoxes)
        }

        return nil
    }

    func withRemovedContentType(_ contentType: Line.ContentType) -> Self {
        let lines: [Line] = lines.map { line in
            if line.contentType == contentType {
                return Line(textBlocks: line.textBlocks, linkedLines: line.linkedLines, contentType: .unknown)
            } else {
                return line
            }
        }

        return RecognizedContent(lines: lines, allCharBoxes: allCharBoxes, allTextBoxes: allTextBoxes)
    }
}

extension RecognizedContent {
        static private var possibleDateFormats = ["dd/MM/yy", "dd.MM.yy", "yyyy-MM-dd", "dd-MMM-yy"]
        static private var possibleTimeFormats = ["HH:mm", "HH:mm:ss"]

        static func getDateTime(from strings: [String]) -> Date {
            for string in strings {
                if let dateTime = getDateTime(from: string) {
                    return dateTime
                }
            }

            return Date()
        }


        static func getDateTime(from string: String) -> Date? {
            var dateElement: Date?
            var timeElement: Date?

            for subString in string.split(separator: " ") {
                if let date = getDate(from: String(subString)), dateElement == nil {
                    dateElement = date
                    continue
                }

                if let time = getTime(from: String(subString)), timeElement == nil {
                    timeElement = time
                }
            }

            if let dateElement = dateElement {
                if let timeElement = timeElement {
                    let calendar = Calendar.current
                    let dateComponents = calendar.dateComponents([.year, .month, .day], from: dateElement)
                    let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: timeElement)

                    var dateTime = DateComponents()
                    dateTime.year = dateComponents.year
                    dateTime.month = dateComponents.month
                    dateTime.day = dateComponents.day
                    dateTime.hour = timeComponents.hour
                    dateTime.minute = timeComponents.minute
                    dateTime.second = timeComponents.second

                    return calendar.date(from: dateTime)
                }

                return dateElement
            }

            return nil
        }

        static func getTime(from string: String) -> Date? {
            let formatter = DateFormatter()

            for timeFormat in possibleTimeFormats {
                formatter.dateFormat = "yyyy-MM-dd " + timeFormat

                if let time = formatter.date(from: "2000-01-01 " + string) {
                    return time
                }
            }

            return nil
        }

        static func getDate(from string: String) -> Date? {
            let formatter = DateFormatter()

            for subString in string.split(separator: ":") {
                let preparedSubString = subString.trimmingCharacters(in: .whitespacesAndNewlines)

                for dateFormat in possibleDateFormats {
                    formatter.dateFormat = dateFormat

                    if let date = formatter.date(from: preparedSubString) {
                        return date
                    }
                }
            }

            return nil
        }

}
