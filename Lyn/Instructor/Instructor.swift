//
//  Instructor.swift
//  Lyn
//
//  Created by Lakr Aream on 2022/7/22.
//

import Foundation

enum Instructor {
    static let checkMacAddress = "10 FF 30 12".unsafeHexData
    static let disableShutdown = "10 FF 12 00 00".unsafeHexData
    static let enablePrinter = "10 FF F1 03".unsafeHexData
    static let setThickness = "10 FF 10 00 01".unsafeHexData
    static let printLineDots = "1B 4A 40".unsafeHexData
    static let stopPrintJobs = "10 FF F1 45".unsafeHexData
    static let imageCommandHeader = "1D 76 30".unsafeHexData

    static let printerWakeMagic = [String](repeating: "00", count: 1024).joined().unsafeHexData

    struct BLEMessage {
        enum MessageType: String {
            case normal
            case imageLineBuffer
        }

        init(payload: Data, type: MessageType = .normal) {
            self.payload = payload
            self.type = type
        }

        let payload: Data
        let type: MessageType
    }
}

private extension String {
    var unsafeHexData: Data {
        var temp = self
        while temp.contains(" ") {
            temp = temp.replacingOccurrences(of: " ", with: "")
        }
        return Data(hex: temp)!
    }
}
