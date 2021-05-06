// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

protocol AVCaptureServiceAssembler: CaptureServiceAssembler {
}

extension AVCaptureServiceAssembler where Self: Assembler {
    func resolve() -> CaptureService {
        return AVCaptureService()
    }
}