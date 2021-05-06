// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

/// Abstract factory
protocol PanelFactory {

    func createPanel() -> Panel
}
