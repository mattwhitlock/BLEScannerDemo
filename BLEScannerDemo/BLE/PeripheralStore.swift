//
//  Copyright © 2019 Matt Whitlock All rights reserved.
//

import CoreBluetooth

// Keep track of scan results

struct PeripheralStore {
    // MARK: - Properties
    var peripherals: [ScanResult] = []

    mutating func addScanResult(_ peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Check in peripherals
        if let idx = indexOfPeripheralWithIdentifier(peripheral.identifier) {
            peripherals[idx].peripheral = peripheral
            peripherals[idx].advertisementData = advertisementData
            peripherals[idx].rssi = RSSI
            print("Updated peripheral: \(peripheral.name ?? peripheral.identifier.uuidString)")
        } else {
            // Append if not in peripherals
            peripherals.append(ScanResult(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI))
            print("Added peripheral: \(peripheral.name ?? peripheral.identifier.uuidString)")
        }
    }

    func indexOfPeripheralWithIdentifier(_ identifier: UUID) -> Int? {
        return peripherals.firstIndex { $0.peripheral.identifier == identifier }
    }
}
