// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

protocol ORSSerialPortAssembler: SerialPortAssembler {
}

extension ORSSerialPortAssembler where Self: Assembler {
    func resolve() -> SerialPort {
        ORSSerialPortService(settings: resolve())
    }
}
