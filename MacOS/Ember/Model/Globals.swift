// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

class Globals {
    static func availableAspectRatios(for displayAspectRatio: AspectRatio) -> [AspectRatio] {
        [
        .aspectRatio16to9,
        .aspectRatio4to3
        ].filter { $0.ratio <= displayAspectRatio.ratio}
}
}
