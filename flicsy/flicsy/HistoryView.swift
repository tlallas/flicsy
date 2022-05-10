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
    
    static let taskDateFormat: DateFormatter = {
        let formatter = DateFormatter()
//        formatter.dateStyle = .short
        formatter.dateFormat = "MMM d, YYYY"
        return formatter
    }()
    
    
    var body: some View {
            VStack {
                List {
                    ForEach(reflections, id: \.self) { reflection in
                        NavigationLink(destination: HistoryCardView(
                            dailyImage:reflection.image!,
                            title: reflection.title ?? "Untitled",
                            reflection:reflection.text ?? "no text in the reflection",
                            emotion: reflection.emotion ?? "",
                            locality:reflection.locality ?? "",
                            date:reflection.date ?? Date(),
                            country:reflection.country ?? "",
                            region: reflection.administrativeArea ?? "")) {
                        
                            HStack{
                             if let thumbnailImage = UIImage(data: reflection.thumbnail!){
                                Image(uiImage:thumbnailImage)
                                     .cornerRadius(12)
                            }
                        VStack (alignment: .leading){
                            Text("\(reflection.title ?? "Untitled")")
                                .font(.headline)
                                .frame(height: 20)
                                .truncationMode(.tail)
                            Text("\(reflection.text ?? "")")
                                .font(.system(size: 15))
                                .frame(height: 40)
                                .truncationMode(.tail)
                            HStack {
                                Text("\(reflection.date ?? Date(), formatter: Self.taskDateFormat)")
                                    .font(.subheadline)
                                    .fontWeight(.light)
                                Spacer()
                                if let emotion = reflection.emotion {
                                    HStack {
                                        Image(emotion)
                                        Text(emotion)
                                            .font(.system(size: 13))
                                            .foregroundColor(Color("PrimaryColor"))
                                        
                                    }.padding([.leading, .trailing])
                                        .background(Color("AccentColor"))
                                        .cornerRadius(30)
                                }
                            }
                        }.padding(.leading, 5)
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
