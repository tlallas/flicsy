//
//  ContentView.swift
//  flicsy
//
//  Created by Taylor  Lallas on 4/23/22.
//

import SwiftUI

struct ContentView: View {
    @State private var tabSelection = 0
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
                if user.count == 0 {
                    OnboardingView()
                }
                else if user[0].isNewUser == true {
                    OnboardingView()
                } else {
                    TabView (selection: $tabSelection) {
                        NavigationView {
                            VStack{
                                DailyHomeView(tabSelection: $tabSelection, dailyImage: UIImage())

                                Spacer()
                            }
                        }
                        .tag(0)
                        .tabItem {
                            Image(systemName: "house")
                                .resizable()
                        }.background(Color("BackgroundColor"))

                        NavigationView {
                            VStack {
                                HistoryView()
                                Spacer()
                            }
                        }
                        .tag(1)
                        .tabItem {
                            Image(systemName: "square.stack.fill")
                        }.background(Color("BackgroundColor"))
                    }.padding(.bottom, 5)
                 }
            }.background(Color("BackgroundColor"))
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
