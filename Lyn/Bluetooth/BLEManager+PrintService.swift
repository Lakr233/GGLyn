//
//  BLEManager+PrintService.swift
//  Lyn
//
//  Created by Lakr Aream on 2022/7/22.
//

import Cocoa

extension BLEManager {
    func requestPrint(forMessage message: String) {
        print("[*] a print request was made with following message")
        print("===================== MESSAGE =====================")
        print(message)
        print("===================================================")
        DispatchQueue.main.async {
            self.requestWrite(forCommands: Instructor.createPrinterCommand(forText: message))
        }
    }

    func requestPrint(forLocalImageFile url: URL) {
        print("[*] a print request was made to print file at \(url.path)")
        print("====================== IMAGE ======================")
        print(url.path)
        print("===================================================")
        guard let data = try? Data(contentsOf: url),
              let image = NSImage(data: data)
        else {
            return
        }
        DispatchQueue.main.async {
            self.requestWrite(forCommands: Instructor.createPrinterCommand(forImage: image))
        }
    }

    func requestPrint(forImageData imageData: Data) {
        print("[*] a print request was made to print image data")
        print("====================== IMAGE ======================")
        print(imageData.count)
        print("===================================================")
        guard let image = NSImage(data: imageData)
        else {
            return
        }
        guard image.size.width < 2048, image.size.height < 2048 else {
            // 你打我是吧 我不叫疼（x
            return
        }
        DispatchQueue.main.async {
            self.requestWrite(forCommands: Instructor.createPrinterCommand(forImage: image))
        }
    }
}
