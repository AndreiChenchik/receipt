//
//  TextBlock.swift
//  TextBlock
//
//  Created by Andrei Chenchik on 17/8/21.
//

import CoreGraphics

extension RecognizedContent.Line {
struct TextBlock: Codable {
    var text: String
    var boundingBox: CGRect
    var chars: [CGRect]
}
}
