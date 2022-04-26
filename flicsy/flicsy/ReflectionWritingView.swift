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
        Text("Reflection Page")
        VStack {
                TextField(
                    "Write Reflection",
                    text: $reflection
                )
            }
            .textFieldStyle(.roundedBorder)
    }
}

struct ReflectionWritingView_Previews: PreviewProvider {
    static var previews: some View {
        ReflectionWritingView()
    }
}
