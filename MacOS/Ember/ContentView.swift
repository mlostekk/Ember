//
//  ContentView.swift
//  Ember
//
//  Created by Martin Mlostek on 28.04.21.
//

import SwiftUI

struct ContentView: View {
    @State private var blurAmount: CGFloat = 0
    var body: some View {
        Text("Hello, World!")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .blur(radius: blurAmount)

        Slider(value: $blurAmount, in: 0...20)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
