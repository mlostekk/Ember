// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import Cocoa

protocol RenderView: NSView {
    func setImage(_ image: CIImage)
}