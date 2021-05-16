// Copyright (c) 2021 Nomad5. All rights reserved.

import SwiftUI

// https://mokacoding.com/blog/swiftui-dependency-injection/

struct SwiftUISettingsContentView: View {

    @EnvironmentObject var settings: Settings

    var body: some View {
        Text("Hello, World! This is some blur text")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .blur(radius: CGFloat(settings.blurAmount))
        Divider()
        Group {
            Text("Blur amount")
            Slider(value: $settings.blurAmount, in: 0...100)
        }
    }
}


struct SwiftUISettingsContentView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUISettingsContentView()
    }
}
