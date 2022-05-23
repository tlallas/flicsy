//
//  LoadingScreen.swift
//  flicsy
//
//  Created by Taylor  Lallas on 5/23/22.
//

import SwiftUI

struct LoadingScreen: View {
    @Binding var loading : Bool
    @State var loadingTimeRemaining = 3
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @StateObject var historyVM = HistoryViewModel()
    let loadController = LoadController.shared
    
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            ActivityIndicator(isAnimating: true)
        }.onReceive(timer) { _ in
            if loadingTimeRemaining > 1 {
                loadingTimeRemaining -= 1
            } else {
                loading = false
                loadController.stopLoading()
                loadingTimeRemaining = 3
            }
        }.onAppear(perform: {historyVM.fetchReflections()})
    }
}

struct LoadController {
    static let shared = LoadController()
    @State var isLoading : Bool
    
    init () {
        isLoading = true
    }
    
    func stopLoading () {
        isLoading = false
    }
    
    func startLoading () {
        isLoading = true
    }
}


