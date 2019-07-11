//
//  Copyright © 2019 Matt Whitlock All rights reserved.
//

import CoreBluetooth

struct ScanResult {
    // MARK: - Properties
    var peripheral: CBPeripheral
    var advertisementData: [String : Any]
    var rssi: NSNumber

    // MARK: - Computed Properties
    var name: String {
        return peripheral.name ?? "N/A"
    }

    var connectable: Bool {
        let x = advertisementData[CBAdvertisementDataIsConnectable] as? Int ?? 0
        return x == 1
    }

    var uuidString: String {
        return peripheral.identifier.uuidString
    }

    var rssiString: String {
        return "\(rssi)"
    }
}
