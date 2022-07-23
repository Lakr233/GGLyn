//
//  Instructor+Image.swift
//  Lyn
//
//  Created by Lakr Aream on 2022/7/22.
//

import Cocoa
import Foundation

extension Instructor {
    static func createPrinterCommand(forImage image: NSImage) -> [BLEMessage] {
        var commands = [BLEMessage]()
        commands.append(.init(payload: enablePrinter))
        commands.append(.init(payload: setThickness))
        commands.append(.init(payload: printerWakeMagic))
        commands.append(contentsOf: prepareImageData(forImage: image))
        commands.append(.init(payload: printLineDots))
        commands.append(.init(payload: stopPrintJobs))
        return commands
    }

    static func prepareImageData(forImage image: NSImage) -> [BLEMessage] {
        var imageCommand: [BLEMessage] = [
            .init(payload: Instructor.imageCommandHeader),
        ]

        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)?
            .resizeAspectFill(withWidth: Config.printerWidth)?
            .applyingBlackAndWhiteScaleEffect()
        else {
            assertionFailure()
            return .init()
        }

        let width = cgImage.width
        let height = cgImage.height
        let imageRep = NSBitmapImageRep(cgImage: cgImage)

        do {
            /*
             GHIDRA

             imageHeader = CONCAT17((char)(height / 0x100),
                                    CONCAT16((char)height,
                                             CONCAT15((char)(decisionWidth / 0x100),
                                                      CONCAT14((char)decisionWidth,
                                                               CONCAT13(shouldBeZeroForOneByte,0x30761d)))));
             */

            var header = Data()

            let mode: UInt8 = 0x0
            let modeData = withUnsafeBytes(of: mode.littleEndian) { Data($0) }
            header.append(modeData)

            let decisionWidthData = withUnsafeBytes(
                of: UInt16(exactly: width / 8)?.littleEndian ?? 0
            ) { Data($0) }
            header.append(decisionWidthData)

            let decisionHeightData = withUnsafeBytes(
                of: UInt16(exactly: height)?.littleEndian ?? 0
            ) { Data($0) }
            header.append(decisionHeightData)

            imageCommand.append(.init(payload: header))
        }

        for y in 0 ..< height {
            var lineCommand = Data()
            for scanner in 0 ..< width / 8 {
                let head = scanner * 8
                var thisByte: UInt8 = 0
                for i in 0 ..< 8 {
                    let x = head + i
                    if x > Int(width) { continue }
                    guard let color = imageRep
                        .colorAt(x: x, y: y)
                    else {
                        assertionFailure("malformed bitmap")
                        return .init()
                    }
                    if color.colorSpace == NSColorSpace.genericGray || color.colorSpace == NSColorSpace.deviceGray {
                        if color.whiteComponent <= 0.2 { thisByte |= 1 }
                    } else {
                        if let color = color.usingColorSpace(.genericRGB) {
                            if color.redComponent + color.greenComponent + color.blueComponent < 1 { thisByte |= 1 }
                        } else {
                            assertionFailure()
                        }
                    }
                    if i < 7 { thisByte <<= 1 }
                }
                let data = withUnsafeBytes(of: thisByte.littleEndian) { Data($0) }
                lineCommand.append(data)
            }
            imageCommand.append(.init(payload: lineCommand, type: .imageLineBuffer))
        }

        return imageCommand
    }
}
