// Copyright (c) 2021 Nomad5. All rights reserved.

import SwiftUI

// https://mokacoding.com/blog/swiftui-dependency-injection/

struct SwiftUISettingsContentView: View {

    @EnvironmentObject var settings: Settings
    @EnvironmentObject var actions:  Actions

    var body: some View {
        Group {
            Picker("Choose your display", selection: $settings.selectedScreen) {
                ForEach(NSScreen.screens, id: \.self) { screen in
                    Text(screen.localizedName)
                }
            }
            Button("Start") {
                actions.startRenderingSubject.send(())
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
