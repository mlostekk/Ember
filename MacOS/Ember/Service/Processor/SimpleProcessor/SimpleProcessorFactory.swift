// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

/// Processor factory that generates a SimpleProcessor
class SimpleProcessorFactory: ProcessorFactory {

    /// Injected dependencies
    private let settings: Settings

    /// Construction with dependencies
    init(settings: Settings) {
        self.settings = settings
    }

    /// Create a SimpleBarProcessor
    func createProcessorWith(barWidth: CGFloat) -> Processor {
        SimpleProcessor(settings: settings, barWidth: barWidth)
    }
}