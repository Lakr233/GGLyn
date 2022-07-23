//
//  CBPeripheralDelegate.swift
//  Lyn
//
//  Created by Lakr Aream on 2022/7/21.
//

import CoreBluetooth

extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices _: Error?) {
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error _: Error?) {
        print("[*] device \(peripheral.name ?? "?") did discover characteristics for service \(service.uuid)")
        for characteristic in service.characteristics ?? [] {
            peripheral.setNotifyValue(true, for: characteristic)
            peripheral.discoverDescriptors(for: characteristic)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error _: Error?) {
        print("[*] device \(peripheral.name ?? "?") did discover descriptors for characteristic \(characteristic.uuid)")
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error _: Error?) {
        assert(Thread.isMainThread)
        let valueHex = characteristic.value?.hexEncodedString ?? "no value"
        if valueHex != "0101" { // shut up
            print("[*] device \(peripheral.name ?? "?") characteristic \(characteristic.uuid) received \(valueHex)")
        }
        let key = CBPeripheralCharacteristicPair(peripheralIdentifier: peripheral.identifier, characteristicIdentifier: characteristic.uuid.uuidString)
        let callback: CBCharacteristicValueUpdateCallback? = characteristicValueUpdateCallbacks[key]
        if let repeats = callback?.repeats, !repeats {
            characteristicValueUpdateCallbacks.removeValue(forKey: key)
        }
        if let handler = callback?.handler {
            handler(characteristic.value)
        }
    }
}
