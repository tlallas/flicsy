//
//  ReflectionWritingView.swift
//  flicsy
//
//  Created by Taylor  Lallas on 4/24/22.
//

import SwiftUI
import UIKit

struct ReflectionWritingView: View {
    @State private var reflection: String = ""
    var body: some View {
        Text("Reflection for April 26, 2020")
        VStack {
                TextField(
                    "Write Reflection",
                    text: $reflection
                )
        }
        .textFieldStyle(.roundedBorder)
        NavigationLink(destination: CountDown()) {
            Text("Submit")
                .padding()
                .background(Color.white)
        }
    }
}

struct ReflectionWritingView_Previews: PreviewProvider {
    static var previews: some View {
        ReflectionWritingView()
    }
}
