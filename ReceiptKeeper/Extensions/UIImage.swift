//
//  UIImage.swift
//  UIImage
//
//  Created by Andrei Chenchik on 10/8/21.
//

import Foundation
import UIKit

extension UIImage {
    func getLayerWithRects(_ rects: [CGRect], with color: UIColor, using drawingMode: CGPathDrawingMode = .stroke, opacity: CGFloat = 1) -> UIImage {
        let canvasSize = self.size

        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        let image = renderer.image { context in
            context.cgContext.setStrokeColor(color.cgColor)
            context.cgContext.setFillColor(color.cgColor)
            context.cgContext.setAlpha(opacity)
            context.cgContext.setLineWidth(canvasSize.width / 300)

            context.cgContext.addRects(rects)
            context.cgContext.drawPath(using: drawingMode)
        }

        return image
    }

    func croppedToRect(_ rect: CGRect) -> UIImage {
        if let cgImage = self.cgImage, let croppedCGImage = cgImage.cropping(to: rect) {
            return UIImage(cgImage: croppedCGImage)
        }
        else {
            return UIImage()
        }
    }
}

