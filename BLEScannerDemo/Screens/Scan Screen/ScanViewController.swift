//
//  ScanViewController.swift
//
//  Copyright © 2019 Matt Whitlock All rights reserved.
//

import UIKit

class ScanViewController: UITableViewController {
    // MARK: - IBOutlets

    // MARK: - Properties
    var bleManager: BLEManager?
    var detailViewController: DeviceViewController? = nil


    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        checkNil()

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DeviceViewController
        }

        self.title = .localized(.scanScreenTitle)
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        startScanning()
        tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        bleManager?.stopScanning()
    }

    // MARK: - IBActions

    // MARK: - Utility Functions
    private func checkNil() {
    }

    fileprivate func startScanning() {
        bleManager?.add(delegate: self)

        do {
            try bleManager?.startScanning(withServices: nil, options: nil)
        } catch let bleError {
            guard let bleError = bleError as? BLEError else { print("Unhandled error"); return }
            switch bleError {
            case .poweredOff:
                print("PoweredOff")
            case .unauthorized:
                print("Unauthorized")
            case .unavailable:
                print("Unavailable")
            }
        }
    }


    // MARK: - Segues
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showDetail",
            let cell = sender as? ScanResultTableViewCell {
            return cell.scanResult?.connectable ?? false
        } else {
            return false
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail",
            let cell = sender as? ScanResultTableViewCell {
            let deviceViewController = (segue.destination as! UINavigationController).topViewController as! DeviceViewController
            deviceViewController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            deviceViewController.navigationItem.leftItemsSupplementBackButton = true
            deviceViewController.scanResult = cell.scanResult
            deviceViewController.bleManager = bleManager
        }
    }

    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bleManager?.peripheralStore.peripherals.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScanResultCell", for: indexPath) as! ScanResultTableViewCell
        cell.scanResult = bleManager?.peripheralStore.peripherals[indexPath.row]

        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78.0
    }
}


// MARK: - BLEManagerListener
extension ScanViewController: BLEManagerListener {
    func bleAvailable(_ available: Bool) {
        startScanning()
    }

    func peripheralStoreUpdated() {
        tableView.reloadData()
    }
}
