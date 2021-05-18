// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

protocol ProcessorAssembler {
    func resolve() -> Processor
}

extension ProcessorAssembler where Self: Assembler {

    private func createProcessor() -> SimpleImageProcessor {
        let initial = SimpleImageProcessor(settings: resolve())
        register(initial)
        return initial
    }

    func resolve() -> Processor {
        let service = get(type: SimpleImageProcessor.uniqueKey) as? SimpleImageProcessor
        return service ?? createProcessor()
    }
}