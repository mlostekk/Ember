// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import Cocoa

enum WindowPosition {
    case left
    case right
}

/// Abstract factory
protocol WindowFactory {

    func createWindowAt(position: WindowPosition,
                        sourceAspectRatio: AspectRatio,
                        targetScreen: NSScreen) -> Window
}
