//
//  main.swift
//  Lyn
//
//  Created by Lakr Aream on 2022/7/20.
//

import Foundation

autoreleasepool {
    _ = BLEManager.shared
    _ = Server.shared

    CFRunLoopRun()
}
