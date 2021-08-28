// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

protocol SwiftUISettingsViewAssembler {
    func resolve() -> SettingsView
}

extension SwiftUISettingsViewAssembler where Self: Assembler {
    func resolve() -> SettingsView {
        SwiftUISettingsView(imageProcessor: resolve(),
                            settings: resolve(),
                            actions: resolve())
    }
}