//
//  HistoryView.swift
//  flicsy
//
//  Created by Taylor  Lallas on 4/23/22.
//


import SwiftUI
import Firebase
import Foundation
import UIKit
import CoreData

struct HistoryView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @StateObject var historyVM = HistoryViewModel()
    var fromBackButton : Bool
    @Binding var fromSubmit : Bool
    @State var isLoading: Bool = true
    @State var timeRemaining = 3
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
//    init (fromBackButton: Bool, fromSubmit: Bool) {
//        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.init(Color("PrimaryColor"))]
//        self.fromSubmit = fromSubmit
//        self.fromBackButton = fromBackButton
//    }
    
    static let taskDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, YYYY"
        return formatter
    }()
    
    
    var body: some View {
        ZStack {
            Image("HistoryBackground").resizable().ignoresSafeArea()
            VStack {
                if historyVM.reflections.isEmpty {
                    Text("Add to your history by revealing a flic & writing a reflection.")
                        .font(.headline)
                        .foregroundColor(Color("PrimaryColor"))
                        .padding([.leading, .trailing])
                        .padding(.bottom, 100)
                }
                if fromSubmit && isLoading && timeRemaining > 0{
                    VStack {
                        Text("Loading your reflection history...")
                            .font(.headline)
                            .foregroundColor(Color("PrimaryColor"))
                        ActivityIndicator(isAnimating: isLoading)
                    }.onReceive(timer) { _ in
                        if timeRemaining > 1 {
                            timeRemaining -= 1
                        } else {
                            isLoading = false
                            timeRemaining = 3
                            fromSubmit = false 
                        }
                    
                    }.onAppear(perform: {
                        if timeRemaining >= 3 {
                            historyVM.fetchReflections()
                        }
                    })
                } else {
                    List {
                        ForEach(historyVM.reflections, id: \.self) { i in
                            NavigationLink(destination: HistoryCardView(
                                dailyImage: i.image!,
                                title: i.title ?? "Untitled",
                                reflection: i.text ?? "no text in the reflection",
                                emotion: i.emotion ?? "",
                                locality: i.locality ?? "",
                                date: i.date ?? Date(),
                                country: i.country ?? "",
                                region: i.administrativeArea ?? "",
                                timeRemaining: $timeRemaining))
                            {
                                HStack {
                                     if let thumbnailImage = UIImage(data: i.thumbnail!){
                                        Image(uiImage:thumbnailImage)
                                             .cornerRadius(12)
                                         VStack (alignment: .leading){
                                             Text("\(i.title ?? "Untitled")")
                                                 .font(.headline)
                                                 .frame(height: 20)
                                                 .truncationMode(.tail)
                                             Text("\(i.text ?? "")")
                                                 .font(.system(size: 15))
                                                 .frame(height: 40)
                                                 .truncationMode(.tail)
                                             HStack {
                                                 Text("\(i.date ?? Date(), formatter: Self.taskDateFormat)")
                                                     .font(.subheadline)
                                                     .fontWeight(.light)
                                                 Spacer()
                                                 if let emotion = i.emotion {
                                                     HStack {
                                                         Image(emotion)
                                                         Text(emotion)
                                                             .font(.system(size: 13))
                                                             .foregroundColor(Color("PrimaryColor"))
                                                     }.padding([.leading, .trailing])
                                                    .background(Color("BabyBlueColor"))
                                                    .cornerRadius(12)
                                                 }
                                             }
                                         }
                                     }
                                }
                            }
                        }
                    }
                }
            
            }.navigationTitle("History")
                
        }.onAppear(perform: {
            if (timeRemaining != -1) {
                timeRemaining = 3
            }
            if (timeRemaining == -1){
                timeRemaining = 0
            }
            isLoading = true
            Analytics.logEvent("viewed_flic_history", parameters: nil)
            Analytics.logEvent(AnalyticsEventScreenView,
                               parameters: [AnalyticsParameterScreenName: "History List",
                                            AnalyticsParameterScreenClass: "History"])
        })
    
    }
}

//reflections = managedObjectContext.fetch(fetchRequest)

//struct HistoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        HistoryView()
//    }
//}

