//
//  OnboardingView.swift
//  App Onboarding
//
//  Created by Taylor  Lallas on 4/23/22.
//

import SwiftUI
import PhotosUI

struct OnboardingView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    let persistentController = PersistenceController.shared
    @FetchRequest(entity: User.entity(),sortDescriptors:[])
    var user: FetchedResults<User>
    @Binding var inOnboarding : Bool
    
    var titles = ["welcome to", "", "",""]
    
    var headlines =  ["personal photo journaling", "get a random photo surprise", "reflect on your photo", "look back on all your mems"]
    
    var subheadlines = ["for mindfulness, memories, & reflection", "every day from your camera roll", "to capture and relive your memories", "by viewing your photo reflection history"]
    
    
    @State var currentPageIndex = 0
    let exampleColor : Color = Color(red: 147/255, green: 174/255, blue: 212/255)
    
    var body: some View {
        ZStack { // 1
            Color("BackgroundColor").ignoresSafeArea() // 2
            Image("onboardingEllipse").padding(.top, -260).ignoresSafeArea()
            
        VStack(alignment: .center) {
            Group {
                if self.currentPageIndex == 0 {
                    VStack {
                        Text(titles[currentPageIndex])
                            .font(.headline)
                            .padding(.bottom)
                        Text("flicsy")
                            .font(.system(size: 80.0))
                            .fontWeight(.bold)
                            .padding(.top)
                    }
                } else if self.currentPageIndex == 1 {
                    Image("gift").padding(.top, 75)
                } else if self.currentPageIndex == 2 {
                    Image("reflectOnboard")
                        .resizable()
                        .frame(width: 320, height: 277)
                        .padding(.top, 65)
                } else if self.currentPageIndex == 3 {
                    Image("flicHistory")
                        .resizable()
                        .frame(width: 185, height: 340)
                }


            }.foregroundColor(Color("PrimaryColor"))
            .padding([.top], 80)
            Spacer()
            
            VStack {
                Text(headlines[currentPageIndex])
                    .font(.headline)
                Text(subheadlines[currentPageIndex])
                    .font(.subheadline)
                    .fontWeight(.light)
            }.foregroundColor(Color("PrimaryColor"))
                .padding(.bottom, 80)
           
            PageControl(numberOfPages: titles.count, currentPageIndex: $currentPageIndex)
            
            HStack {
                Button(action: {
                    if self.currentPageIndex > 0 {
                        self.currentPageIndex = self.currentPageIndex - 1
                    }
                }) {
                    if (self.currentPageIndex > 0) {
                        ButtonLeftContent()
                    }
                }
                if self.currentPageIndex > 0 {
                    Spacer()
                }
                Button(action: {
                    if self.currentPageIndex+1 == self.titles.count {
                        let newUser = User(context: persistentController.container.viewContext)
                        newUser.isNewUser = false
                        PersistenceController.shared.save()
                        inOnboarding = false
                    }
                    else if self.currentPageIndex == 2{
                    retrieveTodaysFlic()
                        self.currentPageIndex += 1
                    }
                    else {
                        self.currentPageIndex += 1
                    }
                }) {
                    if (self.currentPageIndex == 0) {
                        ButtonStartContent()
                    } else if self.currentPageIndex == 3 {
                        ButtonFinishContent()
                    } else {
                        ButtonRightContent()
                    }
                }
            }.padding(.top)
                .padding(.trailing, 25)
                .padding(.leading, 25)
                .padding(.bottom, 75)
        }}
    }
}

func retrieveTodaysFlic() {
    if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
        PHPhotoLibrary.requestAuthorization({(status: PHAuthorizationStatus) -> Void in ()
        })
    }}

struct ButtonRightContent: View {
    var body: some View {
        HStack {
            Text("Next").foregroundColor(Color("PrimaryColor"))
            Image(systemName: "chevron.right")
            .resizable()
            .foregroundColor(Color("PrimaryColor"))
            .frame(width: 10, height: 20)
            .cornerRadius(30)
        }.padding()
    }
}

struct ButtonLeftContent: View {
    var body: some View {
        HStack {
            Image(systemName: "chevron.left")
            .resizable()
            .foregroundColor(Color("PrimaryColor"))
            .frame(width: 10, height: 20)
            .cornerRadius(30)
            Text("Prev").foregroundColor(Color("PrimaryColor"))
        }.padding()
    }
}

struct ButtonStartContent: View {
    var body: some View {
        HStack {
            Text("Get Started").foregroundColor(Color("PrimaryColor"))
            Image(systemName: "chevron.right")
            .resizable()
            .foregroundColor(Color("PrimaryColor"))
            .frame(width: 10, height: 20)
            .cornerRadius(30)
        }.padding()
    }
}

struct ButtonFinishContent: View {
    var body: some View {
        HStack {
            Text("Finish").foregroundColor(Color("PrimaryColor"))
            Image(systemName: "chevron.right")
            .resizable()
            .foregroundColor(Color("PrimaryColor"))
            .frame(width: 10, height: 20)
            .cornerRadius(30)
        }.padding()
    }
}


