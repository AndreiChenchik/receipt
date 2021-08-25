//
//  DraftLine.swift
//  DraftLine
//
//  Created by Andrei Chenchik on 10/8/21.
//

import Foundation
import CoreGraphics

class DraftLine: ObservableObject, Identifiable, Equatable {
    static func == (lhs: DraftLine, rhs: DraftLine) -> Bool {
        lhs.id == rhs.id
    }

    let id = UUID()

    @Published var label: String
    @Published var value: String
    @Published var selected: Bool

    @Published var boundingBox: CGRect

    var text: String { label + " " + value }

    init(label: String, value: String, selected: Bool, boundingBox: CGRect) {
        self.label = label
        self.value = value
        self.selected = selected
        self.boundingBox = boundingBox
    }
}

extension DraftLine {
    static func buildArray(from recognizedTextLines: [RecognizedContent.Line]) -> [DraftLine] {
        var draftLines = [DraftLine]()
        var totalFound = false

        for line in recognizedTextLines {
            if let value = line.value {
                if line.label.lowercased() == "total" && !totalFound {
                    totalFound = true
                }

                let draftLine = DraftLine(label: line.label, value: String(value), selected: !totalFound, boundingBox: line.boundingBox)
                draftLines.append(draftLine)
            } else {
                let draftLine = DraftLine(label: line.label, value: "", selected: false, boundingBox: line.boundingBox)
                draftLines.append(draftLine)
            }
        }

        return draftLines
    }
}
