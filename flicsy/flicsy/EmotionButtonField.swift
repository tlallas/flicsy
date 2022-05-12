//
//  EmotionButtonField.swift
//  flicsy
//
//  Created by Taylor  Lallas on 5/8/22.
//

import SwiftUI
import UIKit

var emotions =
    ["happy" : 1,
     "silly" : 2,
     "sad" : 3,
     "in love": 4,
     "meh" : 5,
//     "home" : 6,
//     "food" : 7
    ]

var emojiMapDict = [
     "happy" :"\u{1F604}",
     "funny" : "\u{1F602}",
     "sad" : "\u{1F614}",
     "love": "\u{1F60D}",
     "travel" : "\u{2708}",
//     "home" : "\u{1F3E0}",
//     "food" : "\u{1F354}"
]

struct EmotionButtonField: View {
    let id: Int
    let label: String
    let size: CGFloat
    let color: Color
    let bgColor: Color
    let textSize: CGFloat
    let isMarked:Bool
    let callback: (Int)->()
    
    init(
        id: Int,
        label:String,
        size: CGFloat = 20,
        color: Color = Color.black,
        bgColor: Color = Color.black,
        textSize: CGFloat = 14,
        isMarked: Bool = false,
        callback: @escaping (Int)->()
        ) {
        self.id = id
        self.label = label
        self.size = size
        self.color = color
        self.bgColor = bgColor
        self.textSize = textSize
        self.isMarked = isMarked
        self.callback = callback
            
    }
    
    var body: some View {
        Button(action:{
            self.callback(self.id)
        }) {
            VStack(alignment: .center) {
//                Image(systemName: self.isMarked ? "largecircle.fill.circle" : "circle")
//                    .clipShape(Circle())
//                    .foregroundColor(self.bgColor)
//                    .padding(.bottom, 2)
//                Text(emojiMapDict[label] ?? "")
                Image(label)
                Text(label)
                    .font(Font.system(size: textSize))
                Spacer()
            }.padding()
            .foregroundColor(self.color)
            .background(self.isMarked ? Color("BabyBlueColor") : Color.white)
            .cornerRadius(12)
               
        }
        .foregroundColor(Color.white)
    }
}

