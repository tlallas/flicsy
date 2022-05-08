//
//  ReflectionHistoryView.swift
//  flicsy
//
//  Created by Clara Everett on 4/30/22.
//

import SwiftUI

struct ReflectionHistoryView: View {
    @State var dailyImage:Data
    @State var title:String
    @State var reflection:String
    @State var locality:String
    @State var date:Date
    @State var country:String
    

    var body: some View {
        VStack {
            Text("\(title)")
                .font(.title)
            if let img = UIImage(data:dailyImage){
                Image(uiImage:img).resizable().scaledToFill()
            }
            Text(date, style: .date)
                .font(.headline)
            Text("\(country)")
                .font(.headline)
            Text("\(reflection)")
                .font(.headline)
        }
    }
}

struct ReflectionHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
