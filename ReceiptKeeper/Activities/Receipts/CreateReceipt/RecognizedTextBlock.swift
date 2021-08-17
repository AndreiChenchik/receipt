//
//  RecognizedTextBlock.swift
//  RecognizedTextBlock
//
//  Created by Andrei Chenchik on 17/8/21.
//

import Foundation
import CoreGraphics

struct RecognizedTextBlock {
    var text: String
    var boundingBox: CGRect
    var chars: [CGRect]
}
