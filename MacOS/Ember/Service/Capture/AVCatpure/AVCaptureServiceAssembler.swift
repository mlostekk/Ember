// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

protocol AVCaptureServiceAssembler: CaptureServiceAssembler {
}

extension AVCaptureServiceAssembler where Self: Assembler {

    private func createCaptureService() -> AVCaptureService {
        let initial = AVCaptureService(settings: resolve())
        register(initial)
        return initial
    }

    func resolve() -> CaptureService {
        let service = get(type: AVCaptureService.uniqueKey) as? AVCaptureService
        return service ?? createCaptureService()
    }
}