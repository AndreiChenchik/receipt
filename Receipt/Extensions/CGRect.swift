//
//  CGRect.swift
//  CGRect
//
//  Created by Andrei Chenchik on 9/8/21.
//

import Foundation
import CoreGraphics
import Vision

extension CGRect {
    var area: CGFloat { height * width }

    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }

    var lowerMid: CGPoint {
        CGPoint(x: midX, y: minY)
    }

    func filterInnerRects(from rects: [CGRect], with areaIntersectionThreshold: CGFloat) -> [CGRect] {
        var filteredChars = [CGRect]()

        for rect in rects {
            let intersectionArea = rect.intersection(self).area
            let intersectionRatio = intersectionArea / rect.area

            if intersectionRatio > areaIntersectionThreshold {
                filteredChars.append(rect)
            }
        }

        return filteredChars
    }

    func imageRectFromNormalizedRect(with imageSize: CGSize) -> CGRect {
        let scaledBox = VNImageRectForNormalizedRect(self, Int(imageSize.width), Int(imageSize.height))
        let cgTransform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -imageSize.height)

        return scaledBox.applying(cgTransform)
    }
}
