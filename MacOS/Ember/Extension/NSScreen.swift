// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import Cocoa

extension NSScreen {
    var displayId: CGDirectDisplayID {
        deviceDescription[NSDeviceDescriptionKey(rawValue: "NSScreenNumber")] as? CGDirectDisplayID ?? 0
    }

    var aspectRatio: AspectRatio {
        AspectRatio(width: frame.width, height: frame.height)
    }
}
