//
//  CBCentralManagerDelegate.swift
//  Lyn
//
//  Created by Lakr Aream on 2022/7/21.
//

import CoreBluetooth

extension BLEManager: CBCentralManagerDelegate {
    func requestScanIfNeeded(_ central: CBCentralManager) {
        if peripheral == nil {
            print("[*] scanning for devices...")
            central.scanForPeripherals(withServices: nil)
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn { requestScanIfNeeded(central) }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData _: [String: Any], rssi _: NSNumber) {
        if peripheral.name?.hasPrefix(Config.printerNamePrefix) ?? false {
            connectForVerification(central, peripheral: peripheral)
        }
    }

    func connectForVerification(_ central: CBCentralManager, peripheral: CBPeripheral) {
        guard !deviceReady else { return }
        assert(Thread.isMainThread)
        let found = candidates.keys.contains(peripheral.identifier)
        guard !found else { return }
        candidates[peripheral.identifier] = peripheral
        central.connect(peripheral) // <- connect
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("[*] device \(peripheral.name ?? "?") connected, requesting verification...")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        print("[*] awaiting characteristic and descriptors...")
        DispatchQueue.main.asyncAfter(deadline: .now() + Config.bluetoothOperatorDelay) {
            self.validateCharacteristicsAndDescriptors(central, peripheral: peripheral) { result in
                switch result {
                case .success: self.postVerficationSuccess(central, peripheral: peripheral)
                case .failure: self.postVerficationFailure(central, peripheral: peripheral)
                }
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error _: Error?) {
        print("[*] device \(peripheral.name ?? "?") disconnected")
        assert(Thread.isMainThread)
        // remove any callback with this identifier
        characteristicValueUpdateCallbacks = characteristicValueUpdateCallbacks.filter { key, _ in
            key.peripheralIdentifier != peripheral.identifier
        }
        if peripheral.identifier == self.peripheral?.identifier {
            print("[*] target device disconnected, calling for rescan...")
            self.peripheral = nil
            requestScanIfNeeded(central)
        }
    }

    func postVerficationFailure(_ central: CBCentralManager, peripheral: CBPeripheral) {
        assert(Thread.isMainThread)
        print("[E] device \(peripheral.name ?? "?") failed to verify")
        central.cancelPeripheralConnection(peripheral)
        candidates[peripheral.identifier] = nil
    }

    func postVerficationSuccess(_: CBCentralManager, peripheral: CBPeripheral) {
        print("[*] device \(peripheral.name ?? "?") completed verfication, ready to accept printer request")
        assert(Thread.isMainThread)
        self.peripheral = peripheral
        candidates = [:]
        requestPrint(forMessage: "喵喵喵 - v1.0\n[初始化完成] \(Date().formatted())")
    }

    enum VerificationError: Error {
        case invalidCharacteristic
        case invalidMacAddress
        case timeout
    }

    func validateCharacteristicsAndDescriptors(_: CBCentralManager, peripheral: CBPeripheral, completion: @escaping (Result<Void, VerificationError>) -> Void) {
        assert(Thread.isMainThread)

        guard let writeCharacteristic = obtainWriteCharacteristic(forPeripheral: peripheral) else {
            print("[E] device \(peripheral.name ?? "?") failed to discover required characteristic")
            completion(.failure(.invalidCharacteristic))
            return
        }

        var resolved = false
        let requestHandler: (Data?) -> Void = { data in
            assert(Thread.isMainThread)
            guard !resolved else { return }
            resolved = true
            guard let data = data else {
                print("[E] device \(peripheral.name ?? "?") did not respond to mac address query")
                completion(.failure(.invalidMacAddress))
                return
            }
            let macStr = data.hexEncodedString
            // D1S may respond with a mac address
            // D1X may respond with two mac address (in a doubled format 102233A392FC102233A392FC)
            //                                                           ^           ^
            guard macStr.contains(Config.printerMac.replacingOccurrences(of: ":", with: "")) else {
                print("[E] device \(peripheral.name ?? "?") did not respond with required mac address")
                completion(.failure(.invalidMacAddress))
                return
            }
            print("[*] device \(peripheral.name ?? "?") passed verification")
            completion(.success())
        }

        let key = CBPeripheralCharacteristicPair(peripheralIdentifier: peripheral.identifier, characteristicIdentifier: Config.readCharacteristicUUID)
        characteristicValueUpdateCallbacks[key] = .init(handler: requestHandler, repeats: false)
        peripheral.writeValue(Instructor.checkMacAddress, for: writeCharacteristic, type: .withResponse)

        DispatchQueue.main.asyncAfter(deadline: .now() + Config.bluetoothOperatorDelay) {
            guard !resolved else { return }
            resolved = true
            completion(.failure(.timeout))
        }
    }
}
