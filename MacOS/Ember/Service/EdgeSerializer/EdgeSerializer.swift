// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import CoreImage

protocol EdgeSerializer {
    /// Pass in an image, get the edge info
    func serialize(edges: Edges) -> [Color]
}

/// Simple implementation
class SimpleEdgeSerializer: EdgeSerializer {

    /// Injected dependencies
    private let settings: Settings

    /// Construction with dependencies
    init(settings: Settings) {
        self.settings = settings
    }

    /// Main serialize function
    func serialize(edges: Edges) -> [Color] {
        fatalError("serialize(edges:) has not been implemented")
    }
}