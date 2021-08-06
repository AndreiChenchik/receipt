//
//  VNRecognizedTextObservation.swift
//  VNRecognizedTextObservation
//
//  Created by Andrei Chenchik on 6/8/21.
//

import Foundation
import Vision

extension VNRecognizedTextObservation {
    var topCandidate: String? {
        topCandidates(1).first?.string
    }
}
