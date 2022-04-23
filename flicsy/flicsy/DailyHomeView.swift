//
//  DailyHomeView.swift
//  flicsy
//
//  Created by Taylor  Lallas on 4/23/22.
//

import SwiftUI
import PhotosUI

struct DailyHomeView: View {
    var body: some View {
        VStack(spacing: 30){
            Text("This is where the daily photo will pop up!")
            Button {
                if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
                    PHPhotoLibrary.requestAuthorization({(status: PHAuthorizationStatus) -> Void in ()
                    })
                }
                
            } label : {
                Text("Reveal Your Daily Photo")
            }
        }
    }
}

struct DailyHomeView_Previews: PreviewProvider {
    static var previews: some View {
        DailyHomeView()
    }
}
