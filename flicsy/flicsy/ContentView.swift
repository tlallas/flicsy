//
//  ContentView.swift
//  flicsy
//
//  Created by Taylor  Lallas on 4/23/22.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    let loadController = LoadController.shared
    
    @State private var tabSelection = 0
    @State var inOnboarding : Bool = false
    @State var fromSubmit : Bool = false
    @State var loading : Bool = true
    
    let persistentController = PersistenceController.shared
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: User.entity(),sortDescriptors:[])
    var user: FetchedResults<User>
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor(Color("BackgroundColor"))
        loadController.startLoading()
        loading = loadController.isLoading
    }
    
    var body: some View {
        Color("BackgroundColor")
            .edgesIgnoringSafeArea(.all)
            .overlay(
            VStack() {
                if loading {
                    LoadingScreen(loading: $loading)
                } else if inOnboarding {
                    OnboardingView(inOnboarding: $inOnboarding)
                } else if (PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized || PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.notDetermined){
                    NavigationView {
                        VStack{
                            NoPhotoAccessView()
                        }
                    }
                } else {
                    TabView (selection: $tabSelection) {
                        NavigationView {
                            VStack{
                                DailyHomeView(tabSelection: $tabSelection, fromSubmit: $fromSubmit, dailyImage: UIImage())
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
                                HistoryView(fromBackButton: false, fromSubmit: $fromSubmit).onAppear(perform: {
                                    UITableView.appearance().backgroundColor = UIColor.clear
                                    UITableViewCell.appearance().backgroundColor = UIColor.clear
                                })
                            }.onAppear(perform: {print(fromSubmit)})
                        }
                        .tag(1)
                        .tabItem {
                            Image(systemName: "square.stack.fill")
                            Text("History")
                        }.background(Color("BackgroundColor"))
                    }.padding(.bottom, 5).ignoresSafeArea(.keyboard, edges: .bottom)
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


//ideas: check if submission happened in the last 30 seconds
