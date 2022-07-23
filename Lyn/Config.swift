//
//  Config.swift
//  Lyn
//
//  Created by Lakr Aream on 2022/7/21.
//

import Foundation

enum Config {
    static let serverPort = 4545
    static let printerNamePrefix = "LuckP_D1"
    static let printerMac = "10:22:33:A3:92:FC"
    static let readCharacteristicUUID = "FF01"
    static let writeCharacteristicUUID = "FF02"
    static let printerWidth = 384
    static let bluetoothOperatorDelay: TimeInterval = 2
    static let fontSize: CGFloat = 20
}

/*
 (lldb) reg read $arg2
       x1 = 0x0000000100ac3497  "drawGraphicNormal:Mode:"
 (lldb) reg read $arg3
       x2 = 0x000060000308ce10
 (lldb) po 0x000060000308ce10
 <UIImage:0x60000308ce10 anonymous {384, 831} renderingMode=automatic>
 */
