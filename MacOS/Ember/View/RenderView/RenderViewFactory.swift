// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

protocol RenderViewFactory {
    func createRenderView(at placement: Placement) -> RenderView
}
