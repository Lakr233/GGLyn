//
//  CGImage.swift
//  Lyn
//
//  Created by Lakr Aream on 2022/7/22.
//

import Accelerate
import Cocoa
import Foundation

extension CGImage {
    func resizeAspectFill(withWidth targetWidth: Int) -> CGImage? {
        let multiplier = CGFloat(width) / CGFloat(targetWidth)
        let width: Int = targetWidth
        let height = Int(CGFloat(height) / multiplier)

        guard let context = CGContext(
            data: nil,
            width: Int(width),
            height: Int(height),
            bitsPerComponent: 8,
            bytesPerRow: 4 * width,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        ) else { return nil }

        // draw image to context (resizing it)
        context.interpolationQuality = .high
        context.draw(self, in: CGRect(x: 0, y: 0, width: Int(width), height: Int(height)))

        // extract resulting image from context
        return context.makeImage()
    }

    // MARK: PROCESS

    func applyingBlackAndWhiteScaleEffect() -> CGImage? {
        try? applyingBlackAndWhiteScaleEffectThrows()
    }

    private enum ImageProcessError: Error {
        case unknownFormat
    }

    private func vImageGetFormat() throws -> vImage_CGImageFormat {
        guard let format = vImage_CGImageFormat(cgImage: self) else {
            throw ImageProcessError.unknownFormat
        }
        return format
    }

    private func vImageGetSourceBuffer() throws -> vImage_Buffer {
        let format = try vImageGetFormat()
        var sourceImageBuffer = try vImage_Buffer(cgImage: self, format: format)
        var scaledBuffer = try vImage_Buffer(width: Int(sourceImageBuffer.width),
                                             height: Int(sourceImageBuffer.height),
                                             bitsPerPixel: format.bitsPerPixel)
        defer {
            sourceImageBuffer.free()
        }
        vImageScale_ARGB8888(&sourceImageBuffer,
                             &scaledBuffer,
                             nil,
                             vImage_Flags(kvImageNoFlags))
        return scaledBuffer
    }

    private func vImageGetDestBuffer(fromSourceBuffer sourceBuffer: vImage_Buffer, bitsPerPixel: UInt32) throws -> vImage_Buffer {
        try vImage_Buffer(
            width: Int(sourceBuffer.width),
            height: Int(sourceBuffer.height),
            bitsPerPixel: bitsPerPixel
        )
    }

    private func applyingBlackAndWhiteScaleEffectThrows() throws -> CGImage {
        // Declare the three coefficients that model the eye's sensitivity
        // to color.
        let redCoefficient: Float = 0.2126
        let greenCoefficient: Float = 0.7152
        let blueCoefficient: Float = 0.0722

        // Create a 1D matrix containing the three luma coefficients that
        // specify the color-to-grayscale conversion.
        let divisor: Int32 = 0x1000
        let fDivisor = Float(divisor)

        var coefficientsMatrix = [
            Int16(redCoefficient * fDivisor),
            Int16(greenCoefficient * fDivisor),
            Int16(blueCoefficient * fDivisor),
        ]

        // Use the matrix of coefficients to compute the scalar luminance by
        // returning the dot product of each RGB pixel and the coefficients
        // matrix.
        let preBias: [Int16] = [0, 0, 0, 0]
        let postBias: Int32 = 0

        var sourceBuffer = try vImageGetSourceBuffer()
        var destinationBuffer = try vImageGetDestBuffer(fromSourceBuffer: sourceBuffer, bitsPerPixel: 8)
        var destinationBuffer2 = try vImageGetDestBuffer(fromSourceBuffer: sourceBuffer, bitsPerPixel: 1)

        vImageMatrixMultiply_ARGB8888ToPlanar8(&sourceBuffer,
                                               &destinationBuffer,
                                               &coefficientsMatrix,
                                               divisor,
                                               preBias,
                                               postBias,
                                               vImage_Flags(kvImageNoFlags))

        vImageConvert_Planar8toPlanar1(
            &destinationBuffer,
            &destinationBuffer2,
            nil,
            Int32(kvImageConvert_DitherFloydSteinberg),
            vImage_Flags(kvImageNoFlags)
        )

        // Create a 1-channel, 8-bit grayscale format that's used to
        // generate a displayable image.
        guard let monoFormat = vImage_CGImageFormat(
            bitsPerComponent: 1,
            bitsPerPixel: 1,
            colorSpace: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
            renderingIntent: .defaultIntent
        ) else {
            throw ImageProcessError.unknownFormat
        }

        // Create a Core Graphics image from the grayscale destination buffer.
        return try destinationBuffer2.createCGImage(format: monoFormat)
    }
}
