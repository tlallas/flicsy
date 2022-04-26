//
//  ContentView.swift
//  flicsy
//
//  Created by Taylor  Lallas on 4/23/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(){
            TabbarView()
                .padding(.bottom, 5)    
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
