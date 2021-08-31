//
//  Character-Emoji.swift
//  Character-Emoji
//
//  Created by Andrei Chenchik on 30/8/21.
//

import Foundation

extension Character {
    var isEmoji: Bool { unicodeScalars.first?.properties.isEmoji ?? false }
}
