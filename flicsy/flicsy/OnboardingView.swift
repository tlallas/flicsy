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
    @FetchRequest(entity: User.entity(),sortDescriptors:[])
    var user: FetchedResults<User>
    
    var titles = ["Welcome to Flicsy", "We think reflection is awesome", "Look back on all your memories","Get Started"]
    
    var captions =  ["Each day you will receive a random photo surprise from your camera roll", "You will have the opportunity to write a reflection on the memory captured in your daily photo", "Over time, you will build a collection of photo reflections to help you remember and relive all your favorite moments", "To begin, please give us access to your camera roll"]
    
    @State var currentPageIndex = 0
    let exampleColor : Color = Color(red: 147/255, green: 174/255, blue: 212/255)
    
    var body: some View {
        ZStack { // 1
            exampleColor.ignoresSafeArea() // 2
        VStack(alignment: .center) {
            Group {
                Text(titles[currentPageIndex])
                    .font(.title).multilineTextAlignment(.center).foregroundColor(.white)
                Text(captions[currentPageIndex])
                    .font(.subheadline).multilineTextAlignment(.center).foregroundColor(.white)
            }
            .padding([.top], 80)
            Spacer()
            PageControl(numberOfPages: titles.count, currentPageIndex: $currentPageIndex)
            
            HStack {
                
                Button(action: {
                    if self.currentPageIndex > 0 {
                        self.currentPageIndex = self.currentPageIndex - 1
                    }
                }) {
                    ButtonLeftContent()
                }
                Spacer()
                Button(action: {
                    if self.currentPageIndex+1 == self.titles.count {
                        user[0].isNewUser = false
                        PersistenceController.shared.save()
                    }
                    else if self.currentPageIndex == 2{
                    retrieveTodaysFlic()
                        self.currentPageIndex += 1
                    }
                    else {
                        self.currentPageIndex += 1
                    }
                }) {
                    ButtonRightContent()
                }
            }
                .padding()
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
        Image(systemName: "chevron.right")
        .resizable()
        .foregroundColor(.white)
        .frame(width: 10, height: 20)
        .padding()
        .cornerRadius(30)
    }
}

struct ButtonLeftContent: View {
    var body: some View {
        Image(systemName: "chevron.left")
        .resizable()
        .foregroundColor(.white)
        .frame(width: 10, height: 20)
        .padding()
        .cornerRadius(30)
    }
}

#if DEBUG
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
#endif
