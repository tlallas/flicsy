//
//  DailyHomeView.swift
//  flicsy
//
//  Created by Taylor  Lallas on 4/23/22.
//

import SwiftUI

struct DailyHomeView: View {
    var body: some View {
        VStack(spacing: 30){
            Text("This is where the daily photo will pop up!")
            Button {
                print("testing")
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
