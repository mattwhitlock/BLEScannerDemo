//
//  Copyright © 2019 Matt Whitlock All rights reserved.
//

import UIKit

class ScanResultTableViewCell: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var uuid: UILabel!
    @IBOutlet weak var rssi: UILabel!

    // MARK: - Properties
    var scanResult: ScanResult? {
        didSet {
            name.text = scanResult!.name
            uuid.text = scanResult!.uuidString
            rssi.text = scanResult!.rssiString

            self.accessoryType = scanResult!.connectable ? .disclosureIndicator : .none
        }
    }

    // MARK: - Computed Properties

    // MARK: - Lifecycle Functions
    override func awakeFromNib() {
        super.awakeFromNib()

        checkNil()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Utility Functions
    private func checkNil() {
        assert(name != nil)
        assert(uuid != nil)
        assert(rssi != nil)
    }

    // MARK: - UI Helper Functions
}
