//
//  Baseline.swift
//  Baseline
//
//  Created by Andrei Chenchik on 10/8/21.
//

import Foundation
import CoreGraphics

infix operator ~~: ComparisonPrecedence

extension RecognizedContent.Line {
    struct Baseline {
        static var angleThreshold: CGFloat { CGFloat.pi / 180 * 10 }
        static var midYDifferenceThreshold = 1.0
        static var errorThreshold = 1.0

        static func ~~ (lhs: Baseline, rhs: Baseline) -> Bool {
            let lhsAngle = atan(lhs.slope)
            let rhsAngle = atan(rhs.slope)

            let lineHeight = average([rhs.lineHeight, lhs.lineHeight])

            let leftMaxX = min(lhs.boundingBox.maxX, rhs.boundingBox.maxX)
            let rightMinX = max(lhs.boundingBox.minX, rhs.boundingBox.minX)
            let midX = leftMaxX + (rightMinX - leftMaxX) / 2

            print("minX \(leftMaxX) midX \(midX) maxX \(rightMinX)")

            let midYDifference = abs(lhs.y(midX) - rhs.y(midX)) / lineHeight

            let angleDifference = abs(rhsAngle - lhsAngle)
            let error = min(lhs.averageCharErrorRatio(with: rhs), rhs.averageCharErrorRatio(with: lhs))

            if angleDifference < angleThreshold {
                if midYDifference < midYDifferenceThreshold {
                    return true
                }
            } else if error < errorThreshold {
                return true
            }

            return false
        }

        init(of rects: [CGRect], withBounding boundingBox: CGRect) {
            let points = rects.map { $0.lowerMid }

            let xs = points.map { $0.x }
            let ys = points.map { $0.y }

            let sum1 = Self.average(Self.multiply(ys, xs)) - Self.average(xs) * Self.average(ys)
            let sum2 = Self.average(Self.multiply(xs, xs)) - pow(Self.average(xs), 2)

            self.rects = rects
            self.slope = sum1 / sum2
            self.intercept = Self.average(ys) - slope * Self.average(xs)
            self.boundingBox = boundingBox
        }

        private func averageCharErrorRatio(with baseline: Baseline) -> CGFloat {
            let errors = rects.map { abs($0.midY - baseline.y($0.midX)) }
            let averageError = Self.average(errors)

            return averageError / lineHeight
        }

        private static func multiply(_ a: [CGFloat], _ b: [CGFloat]) -> [CGFloat] {
            return zip(a, b).map(*)
        }

        private static func average(_ input: [CGFloat]) -> CGFloat {
            return input.reduce(0, +) / CGFloat(input.count)
        }

        private func y(_ x: CGFloat) -> CGFloat {
            slope * x + intercept
        }

        private let slope: CGFloat
        private let intercept: CGFloat
        private let rects: [CGRect]
        private var boundingBox: CGRect

        private var lineHeight: CGFloat {
            let heights = rects.map { $0.height }
            return Self.average(heights)
        }
    }
}
