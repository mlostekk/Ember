// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

/// NSWindow implementation of the panel assembler
protocol NSWindowPanelAssembler: PanelAssembler {
}

extension NSWindowPanelAssembler where Self: Assembler {

    func resolve() -> PanelFactory {
        fatalError("resolve() has not been implemented")
    }
}