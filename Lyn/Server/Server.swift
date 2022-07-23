//
//  Server.swift
//  Lyn
//
//  Created by Lakr Aream on 2022/7/21.
//

import Foundation
import GCDWebServer

class Server: NSObject {
    static let shared = Server()

    let server = GCDWebServer()

    override init() {
        super.init()

        // MARK: - HEALTH

        server.addHandler(forMethod: "GET", path: "/health", request: GCDWebServerRequest.self) { _ in
            if let resp = self.checkDeviceReadyOrReturnErrorResponse() { return resp }
            return GCDWebServerDataResponse(text: "ok")
        }

        // MARK: - TEXT

        server.addHandler(forMethod: "GET", path: "/print/text", request: GCDWebServerRequest.self) { request in
            if let resp = self.checkDeviceReadyOrReturnErrorResponse() { return resp }
            guard let message = request.query?["message"] else {
                return GCDWebServerDataResponse(text: "message not found in text")
            }
            guard message.count <= 1024 else {
                return GCDWebServerDataResponse(text: "message too long")
            }
            BLEManager.shared.requestPrint(forMessage: "\(Date().formatted())\n" + message)
            return GCDWebServerDataResponse(text: "ok")
        }

        // MARK: - LOCAL IMAGE

        server.addHandler(forMethod: "GET", path: "/print/local_image", request: GCDWebServerRequest.self) { request in
            if let resp = self.checkDeviceReadyOrReturnErrorResponse() { return resp }
            guard let path = request.query?["path"] else {
                return GCDWebServerDataResponse(text: "path not found")
            }
            let url = URL(fileURLWithPath: path)
            guard url.lastPathComponent.lowercased().hasPrefix("luck_printer_test") else {
                return GCDWebServerDataResponse(text: "file not made for print test")
            }
            BLEManager.shared.requestPrint(forLocalImageFile: url)
            return GCDWebServerDataResponse(text: "ok")
        }

        // MARK: - POST IMAGE

        server.addHandler(forMethod: "POST", path: "/print/image", request: GCDWebServerURLEncodedFormRequest.self) { request in
            guard let request = request as? GCDWebServerURLEncodedFormRequest else {
                return GCDWebServerDataResponse(text: "503")
            }
            if let resp = self.checkDeviceReadyOrReturnErrorResponse() { return resp }
            BLEManager.shared.requestPrint(forImageData: request.data)
            return GCDWebServerDataResponse(text: "ok")
        }

        // MARK: - START

        server.run(withPort: UInt(Config.serverPort), bonjourName: nil)
    }

    func checkDeviceReadyOrReturnErrorResponse() -> GCDWebServerDataResponse? {
        guard BLEManager.shared.deviceReady else {
            return GCDWebServerDataResponse(text: "device not connected")
        }
        return nil
    }
}
