// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

protocol SwiftUISettingsViewAssembler: SettingsViewAssembler {
    func resolve() -> SettingsView
}

extension SwiftUISettingsViewAssembler where Self: Assembler {
    func resolve() -> SettingsView {
        SwiftUISettingsView(settings: resolve(),
                            actions: resolve())
    }
}