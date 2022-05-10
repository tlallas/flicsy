//
//  DailyHomeView.swift
//  flicsy
//
//  Created by Taylor  Lallas on 4/23/22.
//
import SwiftUI
import PhotosUI
import UIKit

struct DailyHomeView: View {
    @Binding var tabSelection: Int
    @State var flipped:Bool = false
    @State var flip:Bool = false
    @State var revealed:Bool = false
    @State var submitted:Bool = false
    @State var typing:Bool = false
    @State var totalSecondsInDay = 24*60*60
    @State var dailyImage:UIImage
    @State var photoDateData : Date = Date()
    @State var photoLocationData : CLLocation = CLLocation()
    @State var photoLocality : String = "" //city
    @State var photoAdministrativeArea : String = "" //state or region
    @State var photoCountry : String = ""
    @State var waitForNext : Bool = false
    @State var countDownTime : Int = 0
    static var date = Date()
    static var calendar = Calendar.current
    static var hours = calendar.component(.hour, from: date)
    static var minutes = calendar.component(.minute, from: date)
    static var seconds = calendar.component(.second, from: date)

    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: RevealController.entity(),
                  sortDescriptors: [])
    var revealController : FetchedResults<RevealController>
    
    
    


    
    let ceo: CLGeocoder = CLGeocoder()
        
    var body: some View {
        Text("flicsy")
            .foregroundColor(Color("PrimaryColor"))
            .font(.title)
            .frame(maxWidth: DailyFlicCard.width - 20, alignment: .leading)
        ZStack {
            if ((revealed && submitted) || waitForNext) {
                CountDownCard(timeRemaining: $countDownTime).opacity(1) 
            } else if (!revealed) {
                RevealCard().opacity(1).onTapGesture {
                    RevealCard().opacity(0)
                    retrieveTodaysFlic()
                    DailyFlicCard(photoDateData: $photoDateData,
                                  photoLocationData: $photoLocationData,
                                  photoLocality: $photoLocality,
                                  photoAdministrativeArea: $photoAdministrativeArea,
                                  photoCountry: $photoCountry,
                                  dailyImage: $dailyImage).opacity(1)
                    revealed = true
                    
                    let date = Date()
                    let calendar = Calendar.current
                    let nextRevealTime = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)
                    
                    
                    //FIRST use
                    if revealController.isEmpty {
                        let controller = RevealController(context: managedObjectContext)
                        controller.nextReveal = nextRevealTime
                        PersistenceController.shared.save()
                        
                    }
                    
                    //UPDATE existing revealController
                    for controller in revealController {
                        controller.nextReveal = nextRevealTime
                        PersistenceController.shared.save()
                    }
                 
                    
                }
            } else if (submitted) {
                ReflectionCard(submitted: $submitted, typing: $typing, date: $photoDateData, dailyImage: $dailyImage, tabSelection: $tabSelection,
                               photoLocality: $photoLocality,
                               photoAdministrativeArea: $photoAdministrativeArea,
                               photoCountry: $photoCountry).opacity(0)
            } else {
                ReflectionCard(submitted: $submitted, typing: $typing, date: $photoDateData, dailyImage: $dailyImage, tabSelection: $tabSelection,
                               photoLocality: $photoLocality,
                               photoAdministrativeArea: $photoAdministrativeArea,
                               photoCountry: $photoCountry).opacity(flipped ? 0 : 1)
                
                DailyFlicCard(photoDateData: $photoDateData,
                              photoLocationData: $photoLocationData,
                              photoLocality: $photoLocality,
                              photoAdministrativeArea: $photoAdministrativeArea,
                              photoCountry: $photoCountry,
                              dailyImage: $dailyImage).opacity(flipped ? 1 : 0)
            }
        }
        .modifier(FlipEffect(flipped: $flipped, angle: flip ? 0 : 180))
        .onTapGesture(count: 1, perform: {
            withAnimation {
                if (!waitForNext && revealed && !submitted && !typing) {
                    flip.toggle()
                }
                if (typing) {
                    typing = false
                }
            }
        })
        VStack {
            Spacer(minLength: DailyFlicCard.spacerHeight)
        }.onAppear(perform: {
            revealed = getRevealed(results: revealController)
            countDownTime = timeInSeconds()
            
            if (revealed) {
                waitForNext = true
            }
        })
    }
    
    //Convert the time into seconds
    func timeInSeconds() -> Int {
        let hoursInSeconds   = Int(DailyHomeView.hours) * 3600
        let minutesInSeconds = Int(DailyHomeView.minutes) * 60
        let secondsInSeconds = Int(DailyHomeView.seconds) * 1
        let secondsRemaining = totalSecondsInDay - (hoursInSeconds + minutesInSeconds + secondsInSeconds)
        return secondsRemaining
    }
    
    func retrieveTodaysFlic() {
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({(status: PHAuthorizationStatus) -> Void in ()
            })
        } else {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.fetchLimit = 10000
            fetchOptions.predicate = NSPredicate(format: "mediaType == \(PHAssetMediaType.image.rawValue) AND !((mediaSubtype & \(PHAssetMediaSubtype.photoScreenshot.rawValue)) == \(PHAssetMediaSubtype.photoScreenshot.rawValue))")
            let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)

            if fetchResult.count > 0 {
                let fetched = fetchResult.count
                let index = Int.random(in: 1..<fetched)
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = true
                PHImageManager.default().requestImage(for: fetchResult.object(at: index) as PHAsset,
                                                      targetSize: PHImageManagerMaximumSize,
                                                      contentMode: PHImageContentMode.aspectFill,
                                                      options: requestOptions, resultHandler: { (image, _) in
                    dailyImage = image!
                    let asset = fetchResult.object(at: index)
                    //Get date from metadata
                    photoDateData = asset.creationDate ?? Date()

                    //Get location from metadata
                    photoLocationData = asset.location ?? CLLocation()
                    //Extract usable location information
                    ceo.reverseGeocodeLocation(photoLocationData, completionHandler: {(placemarks, error) in
                        if (error != nil) {
                            print("Error retrieving location.")
                        }
                        let pm = placemarks! as [CLPlacemark]
                        if pm.count > 0 { //found place
                            let place = placemarks![0]
                            photoLocality = place.locality ?? ""
                            photoAdministrativeArea = place.administrativeArea ?? ""
                            photoCountry = place.country ?? ""
                        }
                    })
                })
            }
        }
    }
}

struct RevealCard:View {
    var body:some View {
        ZStack {
            Image("RevealBackground")
                .resizable()
                .cornerRadius(10)
                .frame(width: DailyFlicCard.width, height: DailyFlicCard.height)
                .overlay(
                    VStack {
                        Text("Reveal")
                            .foregroundColor(Color("PrimaryColor"))
                            .font(.largeTitle)
                        Text("New photo available!")
                                    .font(.subheadline)
                                    .foregroundColor(Color("PrimaryColor"))
                        }
                )
        }.cornerRadius(10)
    }
}

struct DailyFlicCard:View {
    @Binding var photoDateData : Date
    @Binding var photoLocationData : CLLocation
    @Binding var photoLocality : String //city
    @Binding var photoAdministrativeArea : String //state or region
    @Binding var photoCountry : String
    @Binding var dailyImage:UIImage
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
            Image(uiImage: dailyImage).resizable().aspectRatio(contentMode: .fill)
                .layoutPriority(-1).cornerRadius(10).shadow(color: .gray, radius: 5, x: 2, y: 2)
            ZStack {
                Rectangle().fill(Color(.black)).frame(width: DailyFlicCard.width, height: 100, alignment: .bottom).opacity(0.3)
                VStack {
                    Text(photoDateData, style: .date)
                        .font(.title2).foregroundColor(Color.white).frame(maxWidth: DailyFlicCard.width - 20, alignment: .leading)
                    if photoCountry != "" {
                        if photoLocality != "" && photoAdministrativeArea != "" {
                            Text(photoLocality + ", " + photoAdministrativeArea + "|  " + photoCountry)
                                .font(.headline)
                                .foregroundColor(Color.white)
                                .frame(maxWidth: DailyFlicCard.width - 20, alignment: .leading)
                        } else if photoAdministrativeArea != "" {
                            Text(photoAdministrativeArea + "|  " + photoCountry)
                                .font(.headline)
                                .foregroundColor(Color.white)
                                .frame(maxWidth: DailyFlicCard.width - 20, alignment: .leading)
                        } else if photoLocality != "" {
                            Text(photoLocality + "|  " + photoCountry)
                                .font(.headline)
                                .foregroundColor(Color.white)
                                .frame(maxWidth: DailyFlicCard.width - 20, alignment: .leading)
                        }
                    } else {
                        if photoLocality != "" && photoAdministrativeArea != "" {
                            Text(photoLocality + ", " + photoAdministrativeArea)
                                .font(.headline)
                                .foregroundColor(Color.white)
                                .frame(maxWidth: DailyFlicCard.width - 20, alignment: .leading)
                        } else if photoAdministrativeArea != "" {
                            Text(photoAdministrativeArea)
                                .font(.headline)
                                .foregroundColor(Color.white)
                                .frame(maxWidth: DailyFlicCard.width - 20, alignment: .leading)
                        } else if photoLocality != "" {
                            Text(photoLocality)
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

struct ReflectionCard:View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Binding var submitted:Bool
    @Binding var typing:Bool
    @Binding var date: Date
    @Binding var dailyImage: UIImage
    @Binding var tabSelection: Int
    @Binding var photoLocality : String //city
    @Binding var photoAdministrativeArea : String //state or region
    @Binding var photoCountry : String
    @State private var reflectionText: String = ""
    @State private var title: String = ""
    @State var selectedEmotion = 0
    

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .frame(width: DailyFlicCard.width, height: DailyFlicCard.height)
            .shadow(color: .gray, radius: 10, x: 5, y: 5)
            .overlay(
                VStack {
                    TextField(
                        "Untitled Reflection for \(date, style: .date)",
                        text: $title
                    )
                    .padding(.all)
                    .multilineTextAlignment(.center)
                    .onTapGesture {
                        typing = true
                    }
                    
                    HStack {
                        EmotionScrollButtonView(selection: $selectedEmotion)
                    }.padding()
                    Text("Write").frame(maxWidth: .infinity, alignment: .leading).padding(.all)
                    TextField(
                        "What were you doing? How did you feel? ...",
                        text: $reflectionText
                    ).padding(.all, 20).frame(width: 300, height: 200, alignment: .top).onTapGesture {
                        typing = true
                    }
                    Button("Submit", action: submit)
                }
            )
    }
    
    
    func submit() {
        submitted = true
        let reflection = Reflection(context: managedObjectContext)
        reflection.text = reflectionText
        reflection.title = title
        reflection.date = date
        reflection.country = photoCountry
        reflection.administrativeArea = photoAdministrativeArea
        reflection.locality = photoLocality
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
    }
}

struct CountDownCard:View {
    @Binding var timeRemaining:Int
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body:some View {
        return Image("CountdownBackground")
            .resizable()
            .cornerRadius(10)
            .frame(width: DailyFlicCard.width, height: DailyFlicCard.height)
            .overlay(
                VStack {
                    Text("Next reveal in...")
                        .foregroundColor(Color("PrimaryColor"))
                        .font(.largeTitle)
                    Text("\(timeString(time: timeRemaining))")
                                .font(.system(size: 60))
                                .frame(height: 80.0)
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .foregroundColor(Color("PrimaryColor"))
                                .onReceive(timer){ _ in
                                    if self.timeRemaining > 0 {
                                        self.timeRemaining -= 1
                                    }else{
                                        self.timer.upstream.connect().cancel()
                                    }
                                }
                    }.navigationBarHidden(true)
            )
    }
    
    //Convert the time into 24hr (24:00:00) format
    func timeString(time: Int) -> String {
        let hours   = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
}

struct FlipEffect: GeometryEffect {
    
    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }
    
    @Binding var flipped:Bool
    var angle:Double
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        
        DispatchQueue.main.async {
            flipped = angle >= 90 && angle < 270
        }
        
        let newAngle = flipped ? -180 + angle : angle
        
        let angleInRadius = CGFloat(Angle(degrees: newAngle).radians)
        
        var transform3d = CATransform3DIdentity
        transform3d = CATransform3DRotate(transform3d, angleInRadius, 0, 1, 0)
        transform3d = CATransform3DTranslate(transform3d, -size.width / 2, -size.height / 2, 0)
        
        let affineTransform = ProjectionTransform(CGAffineTransform(translationX: size.width / 2, y: size.height / 2))
        
        return ProjectionTransform(transform3d).concatenating(affineTransform)
    }
    
}

var emotionsDictionary =
    ["happy" : 1,
     "silly" : 2,
     "sad" : 3,
     "in love": 4,
     "meh" : 5,
//     "home" : 6,
//     "food" : 7
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

func getRevealed(results: FetchedResults<RevealController>) -> Bool {
    let currDate = Date()
    print(results)
    if (!results.isEmpty) {
        for result in results {
            print("NEXT REVEAL IS")
   
            if let next = result.nextReveal {
                print(next)
                print(currDate)
                if (currDate > next) {
                    print("curr date greater than next")
                    return false;
                } else {
                    print("curr date leq")
                    return true
                }
            }
        }
    }
    print("returning false")
    return false;
}
