//
//  BLEManager.swift
//  BLEScannerDemo
//
//  Copyright © 2019 Matt Whitlock All rights reserved.
//

import CoreBluetooth

protocol BLEManagerListener {
    func bleAvailable(_ available: Bool)
    func peripheralStoreUpdated()
}

final class BLEManager: NSObject { // AnyObject required for CBCentralManagerDelegate
    // MARK: - Properties
    let cbCentralManager = CBCentralManager()
    var peripheralStore = PeripheralStore()
    fileprivate var delegates: [BLEManagerListener] = []

    var cbManagerState: CBManagerState {
        return cbCentralManager.state
    }
    var bleAvailable: Bool {
        return cbManagerState == .poweredOn
    }

    override init() {
        super.init()
        cbCentralManager.delegate = self
    }

    // MARK: - Utility Functions
    func add(delegate: BLEManagerListener) {
        // FIXME: Append/replace.
        delegates.append(delegate)

        // FIXME: May want to fire bleAvailable any time a new delegate is added. Could avoid race condition issues.
    }


    /// Start scanning if BLE available and powered on
    ///
    /// - Parameters:
    ///   - serviceUUIDs: A list of <code>CBUUID</code> objects representing the service(s) to scan for.
    ///   - options: An optional dictionary specifying options for the scan.
    /// - Throws: BLEError
    func startScanning(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]? = nil) throws {
        cbCentralManager.delegate = self

        // Could use self.bleAvailable, but want better handling of errors.
        switch cbManagerState {
        case .poweredOn:
            // Clean up
            peripheralStore.peripherals.removeAll()

            // Start Scanning...
            cbCentralManager.scanForPeripherals(withServices: serviceUUIDs, options: options)
            appStatus.appState = .scanning
            break
        case .poweredOff:
            appStatus.appState = .error
            throw BLEError.poweredOff
        case .resetting: // Update imminent
            appStatus.appState = .error
            throw BLEError.unavailable
        case .unauthorized:
            appStatus.appState = .error
            throw BLEError.unauthorized
        case .unknown: // Update imminent
            appStatus.appState = .error
            throw BLEError.unavailable
        case .unsupported:
            appStatus.appState = .error
            throw BLEError.unavailable
        @unknown default:
            appStatus.appState = .error
            throw BLEError.unavailable
        }
    }

    func stopScanning() {
        if cbCentralManager.isScanning {
            cbCentralManager.stopScan()
            appStatus.appState = .disconnected
        }
    }
}

// MARK: - Handle Core Bluetooth Central Manager events
extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            appStatus.appState = .error
            for delegate in delegates {
                delegate.bleAvailable(false)
            }
        case .poweredOn:
            if cbCentralManager.isScanning {
                appStatus.appState = .scanning
                for delegate in delegates {
                    delegate.bleAvailable(false)
                }
            }
        case .resetting: // Update imminent
            appStatus.appState = .error
        case .unauthorized:
            appStatus.appState = .error
        case .unknown: // Update imminent
            appStatus.appState = .error
        case .unsupported:
            appStatus.appState = .error
        @unknown default:
            fatalError()
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Keep track of peripherals here.
        peripheralStore.addScanResult(peripheral, advertisementData: advertisementData, rssi: RSSI)
        for delegate in delegates {
            delegate.peripheralStoreUpdated()
        }
    }
}
