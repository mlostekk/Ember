// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

protocol EdgeSerializerAssembler {
    func resolve() -> EdgeSerializer
}

extension EdgeSerializerAssembler where Self: Assembler {
    func resolve() -> EdgeSerializer {
        SimpleEdgeSerializer(settings: resolve())
    }
}