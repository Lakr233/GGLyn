//
//  Instructor+Text.swift
//  Lyn
//
//  Created by Lakr Aream on 2022/7/22.
//

import Cocoa
import Foundation

extension Instructor {
    static func createPrinterCommand(forText text: String) -> [BLEMessage] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4

        let attributedText = NSAttributedString(
            string: text,
            attributes: [
                NSAttributedString.Key.font: Config.printerFont,
                NSAttributedString.Key.foregroundColor: NSColor.black,
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
            ]
        )

        let width = CGFloat(Config.printerWidth)
        let height: CGFloat = attributedText.height(containerWidth: width)
        let size = CGSize(width: width, height: height)
        print("[*] resolved message to size \(size)")

        let image = NSImage(size: size)
        let fullRect = NSRect(x: 0, y: 0, width: size.width, height: size.height)

        image.lockFocus()

        NSColor.white.set()

        fullRect.fill()
        attributedText.draw(in: fullRect)

        image.unlockFocus()

        let imageCommand = prepareImageData(forImage: image)
        guard imageCommand.count > 0 else {
            return []
        }

        var commands = [BLEMessage]()
        commands.append(.init(payload: enablePrinter))
        commands.append(.init(payload: setThickness))
        commands.append(.init(payload: printerWakeMagic))
        commands.append(contentsOf: imageCommand) 
        commands.append(.init(payload: printLineDots))
        commands.append(.init(payload: stopPrintJobs))
        return commands
    }
}
