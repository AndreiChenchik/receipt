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

    func cropped(to rect: CGRect) -> UIImage {
        if let cgImage = self.cgImage, let croppedCGImage = cgImage.cropping(to: rect) {
            return UIImage(cgImage: croppedCGImage)
        }
        else {
            return UIImage()
        }
    }
    
}

public extension UIImage {

    /// Extension to fix orientation of an UIImage without EXIF
    func fixOrientation() -> UIImage {

        guard let cgImage = cgImage else { return self }

        if imageOrientation == .up { return self }

        var transform = CGAffineTransform.identity

        switch imageOrientation {

        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))

        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi/2))

        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi/2))

        case .up, .upMirrored:
            break
        @unknown default:
            fatalError("Unknown orientation")
        }

        switch imageOrientation {

        case .upMirrored, .downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)

        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)

        case .up, .down, .left, .right:
            break
        @unknown default:
            fatalError("Unknown orientation")
        }

        if let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: cgImage.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {

            ctx.concatenate(transform)

            switch imageOrientation {

            case .left, .leftMirrored, .right, .rightMirrored:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))

            default:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            }

            if let finalImage = ctx.makeImage() {
                return (UIImage(cgImage: finalImage))
            }
        }

        // something failed -- return original
        return self
    }
}
