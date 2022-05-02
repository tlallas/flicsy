//
//  HistoryView.swift
//  flicsy
//
//  Created by Taylor  Lallas on 4/23/22.
//

import SwiftUI

struct HistoryView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Reflection.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Reflection.date, ascending: false)])
    var reflections: FetchedResults<Reflection>
    
    
    var body: some View {
        
        VStack {
            List {
                
                ForEach(reflections, id: \.self) { reflection in
                    NavigationLink(destination: ReflectionHistoryView(dailyImage:reflection.image!,title: reflection.title ?? "Untitled",  reflection:reflection.text ?? "no text in the reflection",locality:reflection.locality ?? "",date:reflection.date ?? Date(),country:reflection.country ?? "")) {
                    
                        HStack{
                         if let thumbnailImage = UIImage(data: reflection.thumbnail!){
                            Image(uiImage:thumbnailImage)
                        }
                    VStack (alignment: .leading){
                        
                        Text("\(reflection.title ?? "Untitled")")
                            .font(.headline)
                        Text("\(reflection.text ?? "no text in reflection")")
                    }
                    }
                }
            }
        }
        
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
}
