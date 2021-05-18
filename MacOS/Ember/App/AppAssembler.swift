// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

/// Global assembler aggregate which is the main point for
/// the DI to be configured
protocol Assembler: NSWindowPanelAssembler,
                    AVCaptureServiceAssembler,
                    ORSSerialPortAssembler,
                    SwiftUISettingsViewAssembler,
                    PlacementProviderAssembler,
                    SettingsAssembler,
                    ProcessorAssembler,
                    MetalRenderViewAssembler {

    /// Register a new service. Never save global variables anymore
    func register(_ service: Service)

    /// Get a service by class type
    func get(type: String) -> Service?

    /// Reset all registered services
    func reset()
}

/// The main assembler instance that handles dependency resolving
class AppAssembler: Assembler {

    /// The service pool. All single instances go here
    private var services: [String: Service] = [:]

    /// Register a new service that should be treated as a single instance dependency
    func register(_ service: Service) {
        let serviceKey = type(of: service).uniqueKey
        assert(get(type: serviceKey) == nil)
        services[serviceKey] = service
    }

    /// Trigger reset for all single instance services
    func reset() {
        services.forEach { (key, service) in
            service.reset?()
        }
        services.removeAll()
    }

    /// Get a specific single instance service
    @inline(__always)
    func get(type: String) -> Service? {
        services[type]
    }

}

@objc protocol Service {
    static var uniqueKey: String { get }
    @objc optional func reset()
}