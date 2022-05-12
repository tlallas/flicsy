
import SwiftUI
import PhotosUI
import UIKit

struct HistoryCardView: View {
    @State var dailyImage:Data
    @State var title:String
    @State var reflection:String
    @State var emotion:String
    @State var locality:String
    @State var date:Date
    @State var country:String
    @State var region:String
    @State var flipped:Bool = false
    @State var flip:Bool = false
                
    var body: some View {
        Color("BackgroundColor")
            .edgesIgnoringSafeArea(.all)
            .overlay(
                VStack {
                    ZStack {
                        HistoryReflectionCard(title: $title,
                                              reflection: $reflection,
                                              emotion: $emotion,dailyImage: $dailyImage).opacity(flipped ? 0 : 1)
                        HistoryFlicCard(date: $date,
                                      locality: $locality,
                                      region: $region,
                                      country: $country,
                                      dailyImage: $dailyImage).opacity(flipped ? 1 : 0)
                    }
                    .modifier(FlipEffect(flipped: $flipped, angle: flip ? 0 : 180))
                    .onTapGesture(count: 1, perform: {
                        withAnimation {
                            flip.toggle()
                        }
                    }).navigationBarTitleDisplayMode(.inline)
                        .navigationTitle("History")
                        
                        
            })
    }
}


struct HistoryFlicCard:View {
    @Binding var date : Date
    @Binding var locality : String //city
    @Binding var region : String //state or region
    @Binding var country : String
    @Binding var dailyImage: Data
    static var bounds = UIScreen.main.bounds
    static var width = bounds.size.width * 0.9
    static var height = bounds.size.height * 0.75
    static var imageWidth = bounds.size.width * 0.8
    static var imageHeight = bounds.size.height * 0.53
    static var spacerHeight = bounds.size.height * 0.10

    
    var body:some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.white))
                .aspectRatio(9/16, contentMode: .fit)
            if let img = UIImage(data:dailyImage){
                Image(uiImage:img).resizable().aspectRatio(contentMode: .fill)
                    .layoutPriority(-1).cornerRadius(10).shadow(color: .gray, radius: 5, x: 2, y: 2)
            }
            ZStack {
                Rectangle().fill(Color(.black)).frame(width: DailyFlicCard.width, height: 100, alignment: .bottom).opacity(0.3)
                VStack {
                    Text(date, style: .date)
                        .font(.title2).foregroundColor(Color.white).frame(maxWidth: DailyFlicCard.width - 20, alignment: .leading)
                    if country != "" {
                        if locality != "" && region != "" {
                            Text(locality + ", " + region + "|  " + country)
                                .font(.headline)
                                .foregroundColor(Color.white)
                                .frame(maxWidth: DailyFlicCard.width - 20, alignment: .leading)
                        } else if region != "" {
                            Text(region + "|  " + country)
                                .font(.headline)
                                .foregroundColor(Color.white)
                                .frame(maxWidth: DailyFlicCard.width - 20, alignment: .leading)
                        } else if locality != "" {
                            Text(locality + "|  " + country)
                                .font(.headline)
                                .foregroundColor(Color.white)
                                .frame(maxWidth: DailyFlicCard.width - 20, alignment: .leading)
                        }
                    } else {
                        if locality != "" && region != "" {
                            Text(locality + ", " + region)
                                .font(.headline)
                                .foregroundColor(Color.white)
                                .frame(maxWidth: DailyFlicCard.width - 20, alignment: .leading)
                        } else if region != "" {
                            Text(region)
                                .font(.headline)
                                .foregroundColor(Color.white)
                                .frame(maxWidth: DailyFlicCard.width - 20, alignment: .leading)
                        } else if locality != "" {
                            Text(locality)
                                .font(.headline)
                                .foregroundColor(Color.white)
                                .frame(maxWidth: DailyFlicCard.width - 20, alignment: .leading)
                        }
                    }
                }
            }.frame(maxHeight: DailyFlicCard.height, alignment: .bottom)
        }.clipped().cornerRadius(10)
    }
}

struct HistoryReflectionCard:View {
    @Binding var title:String
    @Binding var reflection:String
    @Binding var emotion: String
    @Binding var dailyImage: Data
    
    func shareButton() {
            let activityController = UIActivityViewController(activityItems: [reflection,dailyImage], applicationActivities: nil)

            UIApplication.shared.windows.first?.rootViewController!.present(activityController, animated: true, completion: nil)
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color("PrimaryColor"))
            .frame(width: DailyFlicCard.width, height: DailyFlicCard.height)
            .overlay(
                VStack {
                    if (emotion != "") {
                        VStack() {
                            Image(emotion)
                            Text(emotion).font(Font.system(size: 12))
                        }.padding()
                            .foregroundColor(Color.white)
                            .frame(maxWidth: DailyFlicCard.width, maxHeight: (DailyFlicCard.width * 0.20), alignment: .top)
                            .background(Color("HeaderColor"))
                            .cornerRadius(10)
                    } else {
                        Spacer()
                    }
                    if (title == "Untitled Reflection") {
                        Text("Untitled Reflection").font(.largeTitle).padding().foregroundColor(Color.white)
                    } else {
                        Text(title).font(.largeTitle).padding().foregroundColor(Color.white)
                    }
                    if (reflection == "Write reflection...") {
                        Text("").frame(maxWidth: .infinity, alignment: .center).padding().font(.title).foregroundColor(Color("PrimaryColor"))
                    } else {
                        Text(reflection)
                            .padding().font(.body).foregroundColor(Color.white)
                        Spacer()
                    }
                    Spacer()
                    Button("Share", action: shareButton)
                        .foregroundColor(Color.white)
                        .font(.title2)
                    Spacer()
                }.frame(maxWidth:DailyFlicCard.width, maxHeight: DailyFlicCard.height)
            )
    }
}
