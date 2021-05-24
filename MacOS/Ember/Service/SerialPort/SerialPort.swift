// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

/// Serial port for sending out info to the LEDs
protocol SerialPort {
    /// Open the port
    func open()
    /// Close the port
    func close()
    /// Send out colors
    func send(colors: [Color])
}
