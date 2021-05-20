// Copyright (c) 2021 Nomad5. All rights reserved.

import SwiftUI

// https://mokacoding.com/blog/swiftui-dependency-injection/

struct SwiftUISettingsContentView: View {

    @EnvironmentObject var settings:  Settings
    @EnvironmentObject var actions:   Actions
    @State var             isRunning: Bool = false

    var body: some View {
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
            if isRunning{
                Button("Stop") {
                    actions.stopRenderingSubject.send(())
                    isRunning = false
                }
            }
            else {
                Button("Start") {
                    actions.startRenderingSubject.send(())
                    isRunning = true
                }
            }
            Divider()
            Group {
                Text("Blur amount \(settings.blurAmount)")
                Slider(value: $settings.blurAmount, in: 0...100)
            }
            Divider()
            Group {
                Text("Framerate \(Int(settings.frameRate))")
                Slider(value: $settings.frameRate, in: 1...100)
            }
        }.padding()
    }
}


struct SwiftUISettingsContentView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUISettingsContentView()
    }
}
