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

    @EnvironmentObject var settings:         Settings
    @EnvironmentObject var actions:          Actions
    @State var             isRunning:        Bool                   = false
    @State var             previewSelection: Settings.PreviewSource = .input
    let                    metalRenderView:  MetalRenderView

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
                    ForEach(Globals.availableAspectRatios(for: settings.selectedScreen.aspectRatio), id: \.self) { aspectRatio in
                        Text(aspectRatio.description)
                    }
                }.disabled(isRunning)
            }
            // start / stop button
            Group {
                Button(action: {
                    if isRunning {
                        actions.stopRenderingSubject.send(())
                    } else {
                        actions.startRenderingSubject.send(())
                    }
                    isRunning = !isRunning
                }) {
                    Text(isRunning ? "Stop" : "Start")
                            .font(.system(size: 25))
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 8).foregroundColor(.blue))
                            .frame(width: 100)
                }.buttonStyle(PlainButtonStyle())
                Divider()
            }
            // blur amount
            Group {
                Text("Blur amount \(settings.blurAmount)")
                Slider(value: $settings.blurAmount, in: 0...100)
                Divider()
            }
            // scale
            Group {
                Text("Scaling: \(settings.scale)")
                Slider(value: $settings.scale, in: 1...2)
                Divider()
            }
            // framerate
            Group {
                Text("Framerate \(Int(settings.frameRate))")
                Slider(value: $settings.frameRate, in: 1...100)
                Divider()
            }
            #if PREVIEW_IN_SETTINGS
                // preview
                Group {
                    Form {
                        Picker("Preview source", selection: $settings.previewSource) {
                            ForEach(Settings.PreviewSource.allCases, id: \.localizedName) { value in
                                Text(value.localizedName).tag(value)
                            }
                        }
                    }
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
            #endif
        }.padding()
    }
}
