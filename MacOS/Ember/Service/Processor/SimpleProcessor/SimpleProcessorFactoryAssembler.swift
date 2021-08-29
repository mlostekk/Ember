// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

protocol SimpleProcessorFactoryAssembler {
    func resolve() -> ProcessorFactory
}

extension SimpleProcessorFactoryAssembler where Self: Assembler {

    func resolve() -> ProcessorFactory {
        SimpleProcessorFactory(settings: resolve())
    }
}