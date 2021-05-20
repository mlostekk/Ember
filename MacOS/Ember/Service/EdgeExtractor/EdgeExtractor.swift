// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import CoreImage

struct Edges {
    let top:    Array<CGColor>
    let right:  Array<CGColor>
    let bottom: Array<CGColor>
    let left:   Array<CGColor>
}

protocol EdgeExtractor {
    /// Pass in an image, get the edge info
    func extract(from image: CIImage) -> Edges
}

/// Simple implementation
class SimpleEdgeExtractor: EdgeExtractor {

    /// Injected dependencies
    private let settings: Settings

    /// Construction with dependencies
    init(settings: Settings) {
        self.settings = settings
    }

    /// Main trigger
    func extract(from image: CIImage) -> Edges {
        fatalError("extract(from:) has not been implemented")
    }
}