// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

protocol PlacementProviderAssembler {
    func resolve() -> PlacementProvider
}

extension PlacementProviderAssembler where Self: Assembler {
    func resolve() -> PlacementProvider {
        StaticMainDisplayPlacementProvider()
    }
}