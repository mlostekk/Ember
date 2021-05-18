// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

protocol MetalRenderViewAssembler: RenderViewAssembler {

}

extension MetalRenderViewAssembler where Self: Assembler {
    func resolve() -> RenderViewFactory {
        MetalRenderViewFactory(placementProvider: resolve(),
                               settings: resolve())
    }
}