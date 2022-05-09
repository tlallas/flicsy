//
//  OnboardingView.swift
//  App Onboarding
//
//  Created by Andreas Schultz on 10.08.19.
//  Copyright © 2019 Andreas Schultz. All rights reserved.
//

import SwiftUI
import PhotosUI

struct OnboardingView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: User.entity(),sortDescriptors:[])
    var user: FetchedResults<User>
    
    var subviews = [
        UIHostingController(rootView: Subview(imageString: "meditating")),
        UIHostingController(rootView: Subview(imageString: "skydiving")),
        UIHostingController(rootView: Subview(imageString: "sitting"))
    ]
    
    var titles = ["Welcome to Flicsy", "Set Photo Permissions", "Get Started"]
    
    var captions =  ["Take your time out and bring awareness into your everyday life", "Please give us access", "Regular medidation sessions creates a peaceful inner mind"]
    
    @State var currentPageIndex = 0
    
    
    var body: some View {
        VStack(alignment: .leading) {
            PageViewController(currentPageIndex: $currentPageIndex, viewControllers: subviews)
            Group {
                Text(titles[currentPageIndex])
                    .font(.title)
                
                
            }
                .padding()
         
             
          
            PageControl(numberOfPages: subviews.count, currentPageIndex: $currentPageIndex)
            HStack {
                
                Button(action: {
                    if self.currentPageIndex > 0 {
                        self.currentPageIndex = self.currentPageIndex - 1
                    }
                }) {
                    ButtonLeftContent()
                }
                Button(action: {
                    if self.currentPageIndex+1 == self.subviews.count {
                        user[0].isNewUser = false
                        PersistenceController.shared.save()
                    } else if self.currentPageIndex == 0{
                    retrieveTodaysFlic()
                    }
                    else {
                        self.currentPageIndex += 1
                    }
                }) {
                    ButtonRightContent()
                }
            }
                .padding()
        }
    }
}

func retrieveTodaysFlic() {
    if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
        PHPhotoLibrary.requestAuthorization({(status: PHAuthorizationStatus) -> Void in ()
        })
    }}

struct ButtonRightContent: View {
    var body: some View {
        Image(systemName: "arrow.right")
        .resizable()
        .foregroundColor(.white)
        .frame(width: 15, height: 15)
        .padding()
        .background(Color.blue)
        .cornerRadius(30)
    }
}

struct ButtonLeftContent: View {
    var body: some View {
        Image(systemName: "arrow.left")
        .resizable()
        .foregroundColor(.white)
        .frame(width: 15, height: 15)
        .padding()
        .background(Color.blue)
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
