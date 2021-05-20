// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

protocol EdgeExtractorAssembler {
    func resolve() -> EdgeExtractor
}

extension EdgeExtractorAssembler where Self: Assembler {
    func resolve() -> EdgeExtractor {
        SimpleEdgeExtractor(settings: resolve())
    }
}