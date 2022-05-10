
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
        Text("History").font(.title)
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
        })
        VStack {
            Spacer(minLength: DailyFlicCard.spacerHeight)
        }
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
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .frame(width: DailyFlicCard.width, height: DailyFlicCard.height)
            .shadow(color: .gray, radius: 10, x: 5, y: 5)
            .overlay(
                VStack {
                    if let img = UIImage(data:dailyImage){
                        Image(uiImage:img).resizable().scaledToFill().frame(width: DailyFlicCard.imageWidth, height: DailyFlicCard.imageHeight, alignment: .center).scaledToFit()
                    }
                    HStack {
                        Text(date, style: .date)
                            .font(.title2)
                        Spacer()
                    }.padding(.leading)
                    HStack {
                        if locality != "" && region != "" {
                            Text(locality + ", " + region).font(.headline)
                        } else if region != "" {
                            Text(region).font(.headline)
                        } else if locality != "" {
                            Text(locality).font(.headline)
                        }
                        if country != "" {
                            Text("|  " + country)
                                .font(.headline)
                        }
                        Spacer()
                    }.padding(.leading)
                    
                }
            )
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
            .fill(Color.white)
            .frame(width: DailyFlicCard.width, height: DailyFlicCard.height)
            .shadow(color: .gray, radius: 10, x: 5, y: 5)
            .overlay(
                VStack {
                    if (title == "") {
                        Text("Untitled Reflection").font(.largeTitle).padding()
                    } else {
                        Text(title).font(.largeTitle).padding()

                    }
                    if (emotion == "") {
                        Text("").frame(maxWidth: .infinity, alignment: .center).padding(.all).font(.title)
                    } else {
                        Text("Category").frame(maxWidth: .infinity, alignment: .leading).padding(.all).font(.title)
                        VStack(alignment: .center) {
                            if let emojiStr = emojiMapDict[emotion] {
                                Text(emojiStr)
                                    .font(.body)
                                Text(emotion).font(.body)
                            }
                        }.padding()
                    }
                    if (reflection == "") {
                        Text("").frame(maxWidth: .infinity, alignment: .center).padding().font(.title)
                    } else {
                        Text("Your Reflection").frame(maxWidth: .infinity, alignment: .leading).padding().font(.title)
                        Text(reflection)
                            .padding().font(.body)
                    }
                    Button(action: shareButton) {
                        Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.black)
                    }
                }
            )
    }
}
