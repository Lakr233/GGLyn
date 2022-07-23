//
//  BLEManager.swift
//  Lyn
//
//  Created by Lakr Aream on 2022/7/21.
//

import CoreBluetooth

class BLEManager: NSObject {
    static let shared = BLEManager()

    private let manager: CBCentralManager = .init()

    var peripheral: CBPeripheral? {
        didSet { requestWrite(forCommands: [.init(payload: Instructor.disableShutdown)]) }
    }

    // uuid exists == already requested for verification
    // if fail, remove and release, but keep uuid
    var candidates: [UUID: CBPeripheral?] = [:]

    struct CBPeripheralCharacteristicPair: Codable, Hashable {
        let peripheralIdentifier: UUID
        let characteristicIdentifier: String
    }

    struct CBCharacteristicValueUpdateCallback {
        let handler: (Data?) -> Void
        let repeats: Bool
    }

    var characteristicValueUpdateCallbacks: [CBPeripheralCharacteristicPair: CBCharacteristicValueUpdateCallback] = [:]

    var deviceReady: Bool { peripheral != nil }

    override init() {
        super.init()

        print("[*] initializing CBCentralManager, awaiting state change...")
        manager.delegate = self
    }
}
