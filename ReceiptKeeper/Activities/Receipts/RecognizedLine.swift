//
//  RecognizedLine.swift
//  RecognizedLine
//
//  Created by Andrei Chenchik on 6/8/21.
//

import Foundation
import Vision

struct RecognizedLine: Identifiable {
    let id = UUID()

    var observations = [VNRecognizedTextObservation]()
    var additionalLines = [RecognizedLine]()
    var enabled = false
}

extension RecognizedLine {
    var label: String {
        guard observations.count > 1 else {
            return observations.first?.topCandidateText ?? ""
        }

        let sortedObservations = observations.sorted {
            $0.boundingBox.maxX < $1.boundingBox.maxX
        }

        let count = observations.count > 1 ? observations.count - 1 : observations.count

        var label = sortedObservations[0].topCandidateText ?? ""
        for index in 1..<count {
            label += " " + (sortedObservations[index].topCandidateText ?? "")
        }

        let additionalLines = additionalLines.sorted { $0.boundingBox.maxY < $1.boundingBox.maxY }

        for line in additionalLines {
            if line.boundingBox.maxY > boundingBox.maxY {
                label = line.label + " " + label
            } else {
                label = label + " " + line.label
            }
        }

        return label
    }

    var value: Double? {
        let sortedObservations = observations.sorted {
            $0.boundingBox.maxX < $1.boundingBox.maxX
        }

        if var lastText = sortedObservations.last?.topCandidateText {
            lastText = lastText.replacingOccurrences(of: ",", with: ".")
            if lastText.contains(".") {
                return Double(lastText)
            }
        }

        return nil
    }
}

extension RecognizedLine {
    var boundingBox: CGRect {
        let maxYObservation = observations.max { $0.boundingBox.maxY < $1.boundingBox.maxY }
        let minYObservation = observations.min { $0.boundingBox.minY < $1.boundingBox.minY }
        let maxXObservation = observations.max { $0.boundingBox.maxX < $1.boundingBox.maxX }
        let minXObservation = observations.min { $0.boundingBox.minX < $1.boundingBox.minX }

        let maxY = maxYObservation?.boundingBox.maxY ?? 0
        let minY = minYObservation?.boundingBox.minY ?? 0
        let maxX = maxXObservation?.boundingBox.maxX ?? 0
        let minX = minXObservation?.boundingBox.minX ?? 0

        let height = maxY - minY
        let width = maxX - minX

        return CGRect(x: minX, y: minY, width: width, height: height)
    }
}
