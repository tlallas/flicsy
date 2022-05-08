//
//  ContentView.swift
//  flicsy
//
//  Created by Taylor  Lallas on 4/23/22.
//

import SwiftUI

struct ContentView: View {
    @State private var tabSelection = 0
    
    
    var body: some View {
        VStack(){
            TabView (selection: $tabSelection){
                NavigationView {
                    VStack{
                        DailyHomeView(dailyImage: UIImage(), tabSelection: $tabSelection)
                        Spacer()
                    }
                }
                .tag(0)
                .tabItem {
                    Image(systemName: "house")
                        .resizable()
                    Text("Today's Flic")
                }
                
                NavigationView {
                    VStack {
                        HistoryView()
                        Spacer()
                    }
                }
                .tag(1)
                .tabItem {
                    Image(systemName: "clock")
                    Text("History")
                }
            }.padding(.bottom, 5)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
