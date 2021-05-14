// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

class NSWindowPanelFactory: WindowFactory {

    func createWindow() -> Window {
        return NSWindowPanel()
    }
}