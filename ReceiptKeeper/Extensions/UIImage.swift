//
//  UIImage.swift
//  UIImage
//
//  Created by Andrei Chenchik on 10/8/21.
//

import Foundation
import UIKit

extension UIImage {
    func getLayerWithRects(_ rects: [CGRect], using color: UIColor) -> UIImage {
        let canvasSize = self.size

        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        let image = renderer.image { context in
            context.cgContext.setStrokeColor(color.cgColor)
            context.cgContext.setLineWidth(3)

            context.cgContext.addRects(rects)
            context.cgContext.drawPath(using: .stroke)
        }

        return image
    }
}
