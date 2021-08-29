// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

/// Abstract factory to create a processor
protocol ProcessorFactory {

    /// Create a processor for the given bar width
    func createProcessorWith(barWidth: CGFloat) -> Processor
}
