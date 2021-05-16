// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

protocol SettingsAssembler {
    func resolve() -> Settings
}

extension SettingsAssembler where Self: Assembler
{
    private func createSettings() -> Settings {
        let initial = Settings()
        register(initial)
        return initial
    }

    func resolve() -> Settings {
        let settings = get(type: Settings.uniqueKey) as? Settings
        return settings ?? createSettings()
    }
}