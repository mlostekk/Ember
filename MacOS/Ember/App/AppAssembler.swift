// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

/// Global assembler aggregate which is the main point for
/// the DI to be configured
protocol Assembler: NSWindowPanelAssembler,
                    AVCaptureServiceAssembler,
                    ORSSerialPortAssembler,
                    SwiftUISettingsViewAssembler,
                    PlacementProviderAssembler {

}

/// The main assembler instance that handles dependency resolving
class AppAssembler: Assembler {

}