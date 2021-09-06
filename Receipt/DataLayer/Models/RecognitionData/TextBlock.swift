//
//  TextBlock.swift
//  TextBlock
//
//  Created by Andrei Chenchik on 17/8/21.
//

import Foundation
import CoreGraphics

extension RecognizedContent.Line {
struct TextBlock: Codable, Identifiable {
    let id: UUID
    let text: String
    let boundingBox: CGRect
    let chars: [CGRect]

    init(id: UUID = UUID(), text: String, boundingBox: CGRect, chars: [CGRect]) {
        self.id = id
        self.text = text
        self.boundingBox = boundingBox
        self.chars = chars
    }
}
}
