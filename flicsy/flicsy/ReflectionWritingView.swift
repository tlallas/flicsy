//
//  ReflectionWritingView.swift
//  flicsy
//
//  Created by Taylor  Lallas on 4/24/22.
//

import SwiftUI
import UIKit

struct ReflectionWritingView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var reflectionText: String = ""
    @State private var title: String = ""
    @Binding var dailyImage: UIImage
    @Binding var date: Date
    @Binding var tabSelection: Int
    @Binding var country: String
    @Binding var adminArea: String
    @Binding var locality: String
    @State var selectedEmotion = 0
    
    
    func happy() {
    }
    
    func sad() {
    }
    
    func food() {
    }
    
    func travel() {
    }
        
    var body: some View {
        VStack {
            TextField(
                "Untitled Reflection for \(date, style: .date)",
                text: $title
            )
            .padding(.all)
            .multilineTextAlignment(.center)

            Text("Category").frame(maxWidth: .infinity, alignment: .leading).padding(.all)
            EmotionScrollButtonView(selection: $selectedEmotion)
            
            Text("Write").frame(maxWidth: .infinity, alignment: .leading).padding(.all)
            TextField(
                "What were you doing? How did you feel? ...",
                text: $reflectionText
            ).padding(.all, 20)
        }
        .textFieldStyle(.roundedBorder)
//        NavigationLink(destination: CountDown(dailyImage: $dailyImage)) {
//            Text("Submit")
//                .padding()
//                .background(Color.white)
//        }.onTapGesture {
//            let reflection = Reflection(context: managedObjectContext)
//            reflection.text = reflectionText
//            PersistenceController.shared.save()
//        }
        Button {
            let reflection = Reflection(context: managedObjectContext)
            reflection.text = reflectionText
            reflection.title = title
            reflection.date = date
            reflection.country = country
            reflection.administrativeArea = adminArea
            reflection.locality = locality
            reflection.emotion = emotionsDictionary.first(where: { $0.value == selectedEmotion})?.key
            

            let tempImage = dailyImage
            UIGraphicsBeginImageContext(CGSize(width:75, height: 75))
            tempImage.draw(in: CGRect(x:0, y:0, width:75, height:75))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let pngImageData  = dailyImage.pngData()
            let thumbnailData = newImage?.pngData()
            
            reflection.image = pngImageData
            reflection.thumbnail = thumbnailData
 
            PersistenceController.shared.save()
            self.tabSelection = 1
            
        } label: {
            Text("Submit")
            
        }
    }
}

var emotionsDictionary =
    ["happy" : 1,
     "funny" : 2,
     "sad" : 3,
     "love": 4,
     "travel" : 5,
     "home" : 6,
     "food" : 7
    ]

struct EmotionScrollButtonView : View {
    @Binding var selection : Int
    
    var body: some View {
        ScrollView (.horizontal, showsIndicators: false) {
            HStack {
                ForEach(emotionsDictionary.sorted(by: <), id: \.key) { key, value in
                    EmotionButtonField(
                        id: value,
                        label: key,
                        color:.black,
                        bgColor: .blue,
                        isMarked: $selection.wrappedValue == value ? true : false,
                        callback: { selected in
                            self.selection = selected
                            print("Selection is: \(selected)")
                        }
                    )
                }
            }
        }.frame(height: 50)
    }
}
