//
//  TabBarView.swift
//  SwiftUIStarterKitApp
//
//  Created by Osama Naeem on 02/08/2019.
//  Copyright © 2019 NexThings. All rights reserved.
//

import SwiftUI

struct TabbarView: View {
    var body: some View {
        TabView {
            NavigationView {
                DailyHomeView()
            }
            .tag(0)
            .tabItem {
                Image(systemName: "house")
                    .resizable()
                Text("Today's Flic")
            }
            
            NavigationView {
                HistoryView()
            }
            .tag(1)
            .tabItem {
                Image(systemName: "clock")
                Text("History")
            }
        }
    }
}



