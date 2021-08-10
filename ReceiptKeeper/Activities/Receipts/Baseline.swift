//
//  Baseline.swift
//  Baseline
//
//  Created by Andrei Chenchik on 10/8/21.
//

import Foundation
import CoreGraphics

infix operator ~~: ComparisonPrecedence

struct Baseline {
    static var angleThreshold: CGFloat { CGFloat.pi / 180 * 20 }
    static var interceptDifferenceThreshold = 0.8
    static var errorThreshold = 0.8

    static func ~~ (lhs: Baseline, rhs: Baseline) -> Bool {
        let lhsAngle = atan(lhs.slope)
        let rhsAngle = atan(lhs.slope)

        if abs(rhsAngle - lhsAngle) < angleThreshold {
            let lineHeight = average([rhs.lineHeight, lhs.lineHeight])
            let interceptDifference = abs(lhs.intercept - rhs.intercept) / lineHeight

            if interceptDifference < interceptDifferenceThreshold {
                return true
            }
        } else if min(lhs.averageCharErrorRatio(with: rhs), rhs.averageCharErrorRatio(with: lhs)) < errorThreshold {
            return true
        }

        return false
    }

    init(of rects: [CGRect]) {
        let points = rects.map { $0.lowerMid }

        let xs = points.map { $0.x }
        let ys = points.map { $0.y }

        let sum1 = Self.average(Self.multiply(ys, xs)) - Self.average(xs) * Self.average(ys)
        let sum2 = Self.average(Self.multiply(xs, xs)) - pow(Self.average(xs), 2)

        self.rects = rects
        self.slope = sum1 / sum2
        self.intercept = Self.average(ys) - slope * Self.average(xs)
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

    private var lineHeight: CGFloat {
        let heights = rects.map { $0.height }
        return Self.average(heights)
    }
}
