//
//  Copyright © 2019 Matt Whitlock All rights reserved.
//

import Foundation

// This technique is from https://basememara.com/swifty-localization-xcode-support/

extension Localizable {
    static let scanScreenTitle = Localizable(NSLocalizedString("BLE Devices", comment: "Scan Screen Title"))
    static let deviceScreenTitle = Localizable(NSLocalizedString("Device Details", comment: "Device Screen Title"))

    static let connectingLabel = Localizable(NSLocalizedString("Connecting", comment: "Connecting Label"))
    static let connectedLabel = Localizable(NSLocalizedString("Connected", comment: "Connected Label"))
    static let disconnectedLabel = Localizable(NSLocalizedString("Disconnected", comment: "Disconnected Label"))
    static let failedToConnectLabel = Localizable(NSLocalizedString("Connect Failed", comment: "Failed to Connect Label"))

    static let discoveringServicesLabel = Localizable(NSLocalizedString("Discovering Services", comment: "Discover Services Label"))
    static let discoveredServicesLabel = Localizable(NSLocalizedString("Discovered %d Services", comment: "Discovered Services Label"))

    static let discoveringCharacteristicsLabel = Localizable(NSLocalizedString("Discovering Characteristics", comment: "Discover Characteristics Label"))
    static let discoveredCharacteristicsLabel = Localizable(NSLocalizedString("Discovered %d Total Characteristics\nfor %d of %d Services", comment: "Discovered Characteristics Label"))
}
