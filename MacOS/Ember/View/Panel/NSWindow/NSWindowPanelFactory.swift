// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

class NSWindowPanelFactory: PanelFactory {

    func createPanel() -> Panel {
        return NSWindowPanel()
    }
}