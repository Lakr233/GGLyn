//
//  BLEManager+Printer.swift
//  Lyn
//
//  Created by Lakr Aream on 2022/7/21.
//

import CoreBluetooth

extension BLEManager {
    func obtainWriteCharacteristic(forPeripheral peripheral: CBPeripheral) -> CBCharacteristic? {
        for service in peripheral.services ?? [] {
            for characteristic in service.characteristics ?? [] {
                guard characteristic.uuid.uuidString == Config.writeCharacteristicUUID else {
                    continue
                }
                return characteristic
            }
        }
        return nil
    }

    func requestWrite(forCommands commands: [Instructor.BLEMessage]) {
        assert(Thread.isMainThread)
        let data = commands
            .map(\.payload)
            .reduce(Data(), +)
        guard let peripheral = peripheral,
              peripheral.state == .connected,
              let writeCharacteristic = obtainWriteCharacteristic(forPeripheral: peripheral)
        else {
            return
        }
        peripheral.writeValue(data, for: writeCharacteristic, type: .withResponse)
    }
}
