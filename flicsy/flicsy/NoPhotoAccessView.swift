//
//  NoPhotoAccessView.swift
//  flicsy
//
//  Created by Esmeralda Nava on 5/18/22.
//

import SwiftUI
import Firebase

struct NoPhotoAccessView: View {
    
    var body: some View {
        Color("BackgroundColor")
            .edgesIgnoringSafeArea(.all)
            .overlay(
                VStack {
                    Text("Oops!").foregroundColor(Color("PrimaryColor")).font(.largeTitle).fontWeight(.bold)
                        .padding()
                    
                    Text("Flicsy is a photo app :) To continue, you'll need to allow photo access in Settings").foregroundColor(Color("PrimaryColor")).font(.title2).padding()
                    HStack {
                        Button("Open Settings") {
                            Analytics.logEvent("opened_iphone_settings", parameters: nil)
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                        }.foregroundColor(Color.white).font(.title2)
                    }.padding().background(Color("PrimaryColor")).cornerRadius(40)
                    Spacer()
                }.frame(maxWidth: .infinity, alignment: .center)
            )
    }
        
}



