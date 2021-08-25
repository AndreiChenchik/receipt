//
//  RecognizedObservations.swift
//  RecognizedObservations
//
//  Created by Andrei Chenchik on 25/8/21.
//

import Vision

struct RecognizedObservations {
    let textObservations: [VNRecognizedTextObservation]
    let charObservations: [VNTextObservation]
}
