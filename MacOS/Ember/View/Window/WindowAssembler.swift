// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

/// Abstract assembler
protocol WindowAssembler {

    func resolve() -> WindowFactory

}
