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
    
    var body: some View {
        Text(date, style: .date) // change the hardcoding
        VStack {
                TextField(
                    "Untitled Reflection",
                    text: $title
                )
                TextField(
                    "Write Reflection",
                    text: $reflectionText
                )
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

//struct ReflectionWritingView_Previews: PreviewProvider {
//    static var previews: some View {
//        ReflectionWritingView()
//    }
//}
