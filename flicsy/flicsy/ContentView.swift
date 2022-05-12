//
//  ContentView.swift
//  flicsy
//
//  Created by Taylor  Lallas on 4/23/22.
//

import SwiftUI

struct ContentView: View {
    @State private var tabSelection = 0
    @State var inOnboarding : Bool = false
    let persistentController = PersistenceController.shared
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: User.entity(),sortDescriptors:[])
    var user: FetchedResults<User>
    
    init() {
            UITabBar.appearance().backgroundColor = UIColor(Color("BackgroundColor"))
        }
    
    var body: some View {
        Color("BackgroundColor")
            .edgesIgnoringSafeArea(.all)
            .overlay(
            VStack() {
                if inOnboarding {
                    OnboardingView(inOnboarding: $inOnboarding)
                } else {
                    TabView (selection: $tabSelection) {
                        NavigationView {
                            VStack{
                                DailyHomeView(tabSelection: $tabSelection, dailyImage: UIImage())
                            }
                        }
                        .tag(0)
                        .tabItem {
                            Image(systemName: "house")
                                .resizable()
                            Text("Today's Flic")
                        }.background(Color("BackgroundColor"))

                        NavigationView {
                            VStack {
                                HistoryView()
                            }
                        }
                        .tag(1)
                        .tabItem {
                            Image(systemName: "square.stack.fill")
                            Text("Flic History")
                        }.background(Color("BackgroundColor"))
                    }.padding(.bottom, 5)
                 }
            }.background(Color("BackgroundColor"))
                .onAppear(perform: {
                    if user.isEmpty {
                        inOnboarding = true
                    }
                })
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
