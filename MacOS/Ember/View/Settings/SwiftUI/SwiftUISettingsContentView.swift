// Copyright (c) 2021 Nomad5. All rights reserved.

import SwiftUI
import Combine

// https://mokacoding.com/blog/swiftui-dependency-injection/

struct SettingsPreviewContentView: NSViewRepresentable {

    /// The internal render view
    private let view: MetalRenderView

    /// Construction with dependencies
    init(with view: MetalRenderView) {
        self.view = view
    }

    /// Return the metal view
    func makeNSView(context: Context) -> MetalRenderView {
        view
    }

    /// No-Op
    func updateNSView(_ nsView: MetalRenderView, context: Context) {
    }
}

struct SwiftUISettingsContentView: View {

    @EnvironmentObject var settings:        Settings
    @EnvironmentObject var actions:         Actions
    @State var             isRunning:       Bool = false
    let                    metalRenderView: MetalRenderView

    var body: some View {
        Group {
            // display
            Group {
                Picker("Choose your display", selection: $settings.selectedScreen) {
                    ForEach(NSScreen.screens, id: \.self) { screen in
                        Text(screen.localizedName)
                    }
                }.disabled(isRunning)
                Picker("Choose the aspect ratio", selection: $settings.sourceAspectRatio) {
                    ForEach(Globals.availableAspectRatios, id: \.self) { aspectRatio in
                        Text(aspectRatio.description)
                    }
                }.disabled(isRunning)
            }
            // start / stop button
            Group {
                Button(isRunning ? "Stop" : "Start") {
                    if isRunning {
                        actions.stopRenderingSubject.send(())
                    } else {
                        actions.startRenderingSubject.send(())
                    }
                    isRunning = !isRunning
                }
                Divider()
            }
            // blur amount
            Group {
                Text("Blur amount \(settings.blurAmount)")
                Slider(value: $settings.blurAmount, in: 0...100)
                Divider()
            }
            // framerate
            Group {
                Text("Framerate \(Int(settings.frameRate))")
                Slider(value: $settings.frameRate, in: 1...100)
                Divider()
            }
            // preview
            Group {
                SettingsPreviewContentView(with: metalRenderView)
                        .frame(height: 200.0)
                        .frame(width: 200.0 * (settings.sourceAspectRatio.ratio))
                Divider()
            }
            // serial port
            Group {
                Text("Serial port settings")
                Toggle(isOn: $settings.serialPortEnabled) {
                    Text("Serial port enabled")
                }.disabled(true)
            }

        }.padding()
    }
}
