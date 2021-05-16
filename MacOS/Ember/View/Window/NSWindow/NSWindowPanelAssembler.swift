// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

/// NSWindow implementation of the panel assembler
protocol NSWindowPanelAssembler: WindowAssembler {
}

extension NSWindowPanelAssembler where Self: Assembler {

    func resolve() -> WindowFactory {
        NSWindowPanelFactory(placementProvider: resolve())
    }
}