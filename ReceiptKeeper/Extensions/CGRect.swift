//
//  CGRect.swift
//  CGRect
//
//  Created by Andrei Chenchik on 9/8/21.
//

import Foundation
import CoreGraphics

extension CGRect {
    var area: CGFloat { height * width }

    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }

    var lowerMid: CGPoint {
        CGPoint(x: midX, y: minY)
    }
}
