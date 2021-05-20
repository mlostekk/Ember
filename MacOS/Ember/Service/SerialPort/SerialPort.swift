// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

/// Serial port for sending out info to the LEDs
protocol SerialPort {
    /// Send out colors
    func send(colors: [Color])
}
