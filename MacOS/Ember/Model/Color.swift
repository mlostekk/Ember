// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

struct Color {
    let red:   UInt8
    let green: UInt8
    let blue:  UInt8

    var asArray: [UInt8] {
        [red, green, blue]
    }
}
