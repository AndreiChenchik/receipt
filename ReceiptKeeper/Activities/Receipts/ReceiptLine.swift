//
//  ReceiptLine.swift
//  ReceiptLine
//
//  Created by Andrei Chenchik on 6/8/21.
//

import Foundation
import CoreGraphics
import Vision

struct ReceiptLine: Identifiable {
    let id = UUID()
    let possibleMidYOffset: CGFloat = 0.8
    let possibleXOverlap = 0.02
    var maxY: CGFloat
    var minY: CGFloat
    
    var height: CGFloat { maxY - minY }
    var midY: CGFloat { minY + height / 2 }
    
    var possibleMidRange: ClosedRange<CGFloat> {
        let minMidY = midY - height * possibleMidYOffset
        let maxMidY = midY + height * possibleMidYOffset
        
        return minMidY...maxMidY
    }
    
    func canContain(_ observation: VNRecognizedTextObservation) -> Bool {
        if isMidYInRange(observation) && isNoXOverlap(observation) {
            return true
        } else {
            return false
        }
    }
    
    func isMidYInRange(_ observation: VNRecognizedTextObservation) -> Bool {
        possibleMidRange.contains(observation.boundingBox.midY)
    }
    
    func isYCloseForMerge(_ line: ReceiptLine) -> Bool {
        (minY - line.maxY) < min(height, line.height) / 2
    }
    
    func isNoXOverlap(_ newObservation: VNRecognizedTextObservation) -> Bool {
        let targetWidth = newObservation.boundingBox.width
        let targetWidthRange = newObservation.boundingBox.minX...newObservation.boundingBox.maxX
        var xOverlap: CGFloat = 0
        for observation in observations {
            let observationWidthRange = observation.boundingBox.minX...observation.boundingBox.maxX
            let intersection = targetWidthRange.clamped(to: observationWidthRange)
            let intersectionLength = intersection.upperBound - intersection.lowerBound
            xOverlap += intersectionLength
        }
        
        let overlappedPortion = xOverlap / targetWidth
        return overlappedPortion < possibleXOverlap
    }
    
    mutating func addObservation(_ observation: VNRecognizedTextObservation) {
        observations.append(observation)
        
        minY = min(minY, observation.boundingBox.minY)
        maxY = max(maxY, observation.boundingBox.maxY)
    }
    
    mutating func addObservations(_ observations: [VNRecognizedTextObservation]) {
        for observation in observations {
            addObservation(observation)
        }
    }
    
    var value: Double? {
        let sortedObservations = observations.sorted {
            $0.boundingBox.maxX < $1.boundingBox.maxX
        }
        
        if let lastText = sortedObservations.last?.topCandidateText {
            if lastText.contains(".") {
                return Double(lastText)
            }
        }
        
        return nil
    }
    
    var label: String {
        let sortedObservations = observations.sorted {
            $0.boundingBox.maxX < $1.boundingBox.maxX
        }
        
        let count = observations.count > 1 ? observations.count - 1 : observations.count
        
        var label = ""
        for index in 0..<count {
            label += sortedObservations[index].topCandidateText ?? ""
            label += " "
        }
        
        return label
    }
    
    var observations = [VNRecognizedTextObservation]()
    
    var text: String {
        let sortedObservations = observations.sorted {
            $0.boundingBox.minX < $1.boundingBox.minX
        }
        
        let text = sortedObservations.reduce("") { $0 + " " + ($1.topCandidateText ?? "") }
        
        return text
    }
}
