// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import Cocoa
import SwiftUI
import Combine

/// The main application model
class App {

    /// Dependencies
    private let capture:           CaptureService
    private let processorFactory:  ProcessorFactory
    private let assembler:         Assembler
    private let settingsView:      SettingsView
    private let windowFactory:     WindowFactory
    private let edgeExtractor:     EdgeExtractor
    private let edgeSerializer:    EdgeSerializer
    private let serialPort:        SerialPort
    private let settings:          Settings
    private let actions:           Actions
    private let placementProvider: PlacementProvider
    private var windows:           [WindowPosition: Window] = [:]
    private var processor:         Processor?

    /// The cancel bag
    private var globalCancelBag                             = CancelBag()
    private var windowCancelBag                             = CancelBag()

    /// Construction with dependencies
    init(with assembler: Assembler) {
        self.assembler = assembler
        self.settingsView = assembler.resolve()
        self.windowFactory = assembler.resolve()
        self.processorFactory = assembler.resolve()
        self.settings = assembler.resolve()
        self.actions = assembler.resolve()
        self.edgeExtractor = assembler.resolve()
        self.serialPort = assembler.resolve()
        self.edgeSerializer = assembler.resolve()
        self.placementProvider = assembler.resolve()
        capture = assembler.resolve()
    }

    func start() {
        // settings
        settingsView.show()
        // global start / stop behavior
        globalCancelBag.collect {
            /// Subscribe to start button
            actions.startRenderingStream.sink { [weak self] in
                guard let self = self else { return }
                self.showWindows(sourceAspectRatio: self.settings.sourceAspectRatio, targetScreen: self.settings.selectedScreen)
            }
            /// Subscribe to stop button
            actions.stopRenderingStream.sink { [weak self] in
                guard let self = self else { return }
                self.killWindows()
            }
        }
    }

    private func showWindows(sourceAspectRatio: AspectRatio, targetScreen: NSScreen) {
        // Rendering windows
        windows[.left] = windowFactory.createWindowAt(position: .left, sourceAspectRatio: sourceAspectRatio, targetScreen: targetScreen)
        windows[.right] = windowFactory.createWindowAt(position: .right, sourceAspectRatio: sourceAspectRatio, targetScreen: targetScreen)
        // The processor
        let placementLeft  = placementProvider.getPlacement(for: .left, sourceAspectRatio: sourceAspectRatio, targetScreen: targetScreen)
        let placementRight = placementProvider.getPlacement(for: .right, sourceAspectRatio: sourceAspectRatio, targetScreen: targetScreen)
        assert(placementLeft.barWidth == placementRight.barWidth)
        processor = processorFactory.createProcessorWith(barWidth: placementLeft.barWidth)
        guard let processor = processor else {
            Log.e("Processor could not be created")
            return
        }
        // pass processor to settings for preview view
        settingsView.attach(imageStream: processor.imageStreamFull)

        /// start serial port only if required
        if settings.serialPortEnabled {
            serialPort.open()
        }
        /// listen to images
        windowCancelBag.collect {
            /// Handling the left processed image
            processor.imageStreamLeft.sink { [weak self] ciImage in
                guard let self = self else { return }
                self.windows[.left]?.show(image: ciImage)
            }
            /// Handling the right processed image
            processor.imageStreamRight.sink { [weak self] ciImage in
                guard let self = self else { return }
                self.windows[.right]?.show(image: ciImage)
            }
            /// Handling the full image
            processor.imageStreamFull.sink { [weak self] ciImage in
                guard let self = self else { return }
                /// Extract edges, serialize and send them
                if self.settings.serialPortEnabled {
                    let edges            = self.edgeExtractor.extract(from: ciImage)
                    let serializedColors = self.edgeSerializer.serialize(edges: edges)
                    self.serialPort.send(colors: serializedColors)
                }
            }
            /// Configure capturing & rendering
            capture.pixelBuffer.sink { ciImage in
                processor.process(image: ciImage)
            }
        }
        capture.start()
    }

    private func killWindows() {
        windowCancelBag.removeAll()
        windows.forEach { $1.close() }
        windows.removeAll()
        if settings.serialPortEnabled {
            serialPort.close()
        }
    }

    func stop() {
    }
}