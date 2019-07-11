//
//  DeviceViewController.swift
//  BLEScannerDemo
//
//  Copyright © 2019 Matt Whitlock All rights reserved.
//

import CoreBluetooth
import UIKit

class DeviceViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var rssi: UILabel!
    @IBOutlet weak var uuid: UILabel!
    @IBOutlet weak var connectionStatus: UILabel!
    @IBOutlet weak var discoverServicesStatus: UILabel!
    @IBOutlet weak var discoverCharacteristicsStatus: UILabel!
    @IBOutlet weak var textView: UITextView!

    // MARK: - Properties
    var bleManager: BLEManager?
    var scanResult: ScanResult?
    var discoveredServiceCount = 0
    var discoveredCharacteristicCount = 0

    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        checkNil()

        configureView()

    }

    override func viewWillAppear(_ animated: Bool) {
        configureBLE()
        connectBLE()
    }

    override func viewWillDisappear(_ animated: Bool) {
        bleManager?.cbCentralManager.delegate = nil
        if let peripheral = scanResult?.peripheral {
            peripheral.delegate = nil
            bleManager?.cbCentralManager.cancelPeripheralConnection(peripheral)
        }
        // Dumb but due to splitviewcontroller this is needed.
        do {
            try bleManager?.startScanning(withServices: nil)
        } catch let error{
            print("Error: \(error)")
        }

    }

    // MARK: - IBActions

    // MARK: - Utility Functions
    private func checkNil() {
        assert(name != nil)
        assert(rssi != nil)
        assert(uuid != nil)
        assert(connectionStatus != nil)
        assert(discoverServicesStatus != nil)
        assert(discoverCharacteristicsStatus != nil)
        assert(textView != nil)
        assert(scanResult != nil)
        assert(bleManager != nil)
    }

    private func configureBLE() {
        bleManager?.add(delegate: self)
        bleManager?.cbCentralManager.delegate = self
        scanResult?.peripheral.delegate = self
    }
    private func connectBLE() {
        appStatus.appState = .connecting
        bleManager?.cbCentralManager.connect(scanResult!.peripheral, options: nil)
    }

    // MARK: - UI Helper Functions
    func configureView() {
        connectionStatus.text = .localized(.connectingLabel)
        discoverServicesStatus.text = ""
        discoverCharacteristicsStatus.text = ""
        textView.text = ""
        name.text = scanResult?.name
        rssi.text = scanResult?.rssiString
        uuid.text = scanResult?.uuidString

        navigationItem.title = .localized(.deviceScreenTitle)
    }

}

// MARK: - BLEManagerListener
extension DeviceViewController: BLEManagerListener {
    func bleAvailable(_ available: Bool) {
        if !available {
            // Stop any operation, denote error/disconnected.
        }
    }

    func peripheralStoreUpdated() {
        // Not used
    }
}

// MARK: - CBPeripheralDelegate
extension DeviceViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            discoveredServiceCount = services.count
            discoverServicesStatus.text = .localizedFormat(.discoveredServicesLabel, services.count)
            print("DidDiscoverServices:\n\(services)")

            let servicesString = "Services:\n\(services)"
            textView.text = servicesString

            // Discover Characteristics for each service
            discoveredServiceCount = 0
            discoveredCharacteristicCount = 0
            discoverCharacteristicsStatus.text = .localized(.discoveringCharacteristicsLabel)
            for service in services {
                peripheral.discoverIncludedServices(nil, for: service)
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        discoveredServiceCount += 1
        if let services = peripheral.services,
            let characteristics = service.characteristics {
            discoveredCharacteristicCount += characteristics.count
            discoverCharacteristicsStatus.text = .localizedFormat(.discoveredCharacteristicsLabel, discoveredCharacteristicCount, discoveredServiceCount, services.count)
            print("didDiscoverCharacteristicsForService:\n\(characteristics)")

            var servicesAndCharacteristicsString = "Services and Characteristics:\n"
            for service in services {
                servicesAndCharacteristicsString += " Service:\n  \(service)\n"
                for characteristic in characteristics {
                    servicesAndCharacteristicsString += "   Characteristic:\n   \(characteristic)\n"
                }
            }

            textView.text = servicesAndCharacteristicsString
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        print("didDiscoverIncludedServicesFor")
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("didDiscoverDescriptorsFor")
    }
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        print("didReadRSSI")
    }
}

// MARK: - CBCentralManagerDelegate
extension DeviceViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            appStatus.appState = .error
        case .poweredOn:
            break
//            switch (cbCentralManager.isScanning, connection?.state ?? .disconnected) {
//            case (true, _):
//                appStatus.appState = .scanning
//            case (false, .connected):
//                appStatus.appState = .connected
//            case (false, .connecting):
//                appStatus.appState = .scanning
//            case (false, .disconnected):
//                appStatus.appState = .disconnected
//            case (false, .disconnecting):
//                appStatus.appState = .disconnected
//            @unknown default:
//                fatalError()
//            }
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
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected")
        connectionStatus.text = .localized(.connectedLabel)

        // Scan for Services/Characteristics
        discoverServicesStatus.text = .localized(.discoveringServicesLabel)
        scanResult?.peripheral.discoverServices(nil)
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to Connect")
        connectionStatus.text = .localized(.failedToConnectLabel)
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from Peripheral")
        connectionStatus.text = .localized(.disconnectedLabel)
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("DidDiscoverPeripheral")
    }

}
