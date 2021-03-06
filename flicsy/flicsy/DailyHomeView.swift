//
//  DailyHomeView.swift
//  flicsy
//
//  Created by Taylor  Lallas on 4/23/22.
//
import SwiftUI
import PhotosUI
import UIKit
import FirebaseAnalytics
import Firebase

struct DailyHomeView: View {
    @Binding var tabSelection: Int
    @Binding var fromSubmit: Bool
    @State var flipped:Bool = false
    @State var flip:Bool = false
    @State var onDailyFlicCard:Bool = false
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
    @State var countDownTime : Int = 0
    @State var showSkipModalView : Bool = false
    @State var alreadySkipped = false
    @State var showAlert = false

    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: RevealController.entity(),
                  sortDescriptors: [])
    var revealController : FetchedResults<RevealController>
    
    let ceo: CLGeocoder = CLGeocoder()
    
    var body: some View {
        Color("BackgroundColor")
            .edgesIgnoringSafeArea(.all)
            .overlay(
                VStack {
                    HStack {
                        Text("flicsy")
                            .foregroundColor(Color("PrimaryColor"))
                            .fontWeight(.bold)
                            .font(.title)
                            .frame(maxWidth: DailyFlicCard.width - 50, alignment: .leading)

                        HStack {
                            if (revealed && !submitted && onDailyFlicCard) {
                                Spacer()
                                Text("Tap photo to reflect")
                                    .foregroundColor(Color("PrimaryColor"))
                                    .onTapGesture(perform: {
                                        Analytics.logEvent("tap_to_reflect_tapped", parameters: nil)
                                    }).font(.system(size: 13))
                                    
                                Image(systemName:"arrow.turn.right.down")
                                    .foregroundColor(Color("PrimaryColor"))
                                    .onTapGesture(perform: {
                                        Analytics.logEvent("tap_for_photo_tapped", parameters: nil)
                                    })
                            } else if(revealed && !submitted && !onDailyFlicCard) {
     
                                Text("Tap for photo")
                                    .foregroundColor(Color("PrimaryColor"))
                                    .font(.system(size: 13))
                                   
                                Image(systemName:"arrow.turn.right.down")
                                    .foregroundColor(Color("PrimaryColor"))
                                    
                            }
                        }.frame(maxWidth: DailyFlicCard.width - 20, alignment: .center)
                    }.frame(maxWidth: DailyFlicCard.width)
                    
                    ZStack {
                        if (revealed && !submitted) {
                            if !Calendar.current.isDateInToday(photoDateData) {
                                ReflectionCard(submitted: $submitted,
                                           typing: $typing, date: $photoDateData,
                                           dailyImage: $dailyImage, tabSelection: $tabSelection,
                                           photoLocality: $photoLocality,
                                           photoAdministrativeArea: $photoAdministrativeArea,
                                               photoCountry: $photoCountry, revealController: revealController, fromSubmit: $fromSubmit).opacity(flipped ? 0 : 1)
                            
                                DailyFlicCard(photoDateData: $photoDateData,
                                          photoLocationData: $photoLocationData,
                                          photoLocality: $photoLocality,
                                          photoAdministrativeArea: $photoAdministrativeArea,
                                          photoCountry: $photoCountry,
                                          dailyImage: $dailyImage).opacity(flipped ? 1 : 0)
                                
                            } else {
                                CountDownCard(timeRemaining: $countDownTime).opacity(1)
                                    .onAppear(perform:{
                                        revealed = true
                                        submitted = true
                                    })
                            }
                        } else if (revealed && submitted) {
                            CountDownCard(timeRemaining: $countDownTime).opacity(1)
                                .onAppear(perform: {
                                    Analytics.logEvent("viewed_countdown", parameters: nil)
                                })
                        } else if (!revealed) {
                            RevealCard().opacity(1).onTapGesture {
                                RevealCard().opacity(0)
                                retrieveTodaysFlic()
                                onDailyFlicCard = true
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
                                Analytics.logEvent("tapped_to_reveal", parameters: [
                                    "photoLocality": photoLocality,
                                    "photoAdminArea": photoAdministrativeArea,
                                    "photoCountry": photoCountry
                                ])
                            }
                        }
                    }
                    .modifier(FlipEffect(flipped: $flipped, angle: flip ? 0 : 180))
                    .onTapGesture(count: 1, perform: {
                        hideKeyboard()
                        withAnimation {
                            if (onDailyFlicCard) {
                                onDailyFlicCard = false
                            } else {
                                onDailyFlicCard = true
                            }
                            if (revealed && !submitted && !typing) {
                                flip.toggle()
                                Analytics.logEvent("flipped_photo_ref_card", parameters: nil)
                            } else if (revealed && !submitted){
                                flip.toggle()
                                Analytics.logEvent("flipped_photo_ref_card", parameters: nil)
                            }
                            if (typing) {
                                typing = false
                            }
                        }
                    })
                    Button(action: {
                        if !alreadySkipped {
                            showSkipModalView.toggle()
                            Analytics.logEvent("tried_skip_again", parameters: nil)
                        } else {
                            showAlert.toggle()
                            Analytics.logEvent("skip_pressed", parameters: nil)
                        }
                        }, label: {
                                HStack {
                                    Spacer()
                                    Text("Skip")
                                        .font(.system(size: 11))
                                        
                                    Image(systemName: "forward.fill")
                                        .font(.system(size: 11))
                                }.foregroundColor(Color.gray)
                                .padding([.bottom, .trailing])
                                
                        }).padding(.trailing)
                        .opacity(revealed && !submitted && onDailyFlicCard ? 1 : 0)
                        .sheet(isPresented: $showSkipModalView) {
                            SkipView(isPresented: $showSkipModalView, revealed: $revealed, submitted: $submitted, alreadySkipped: $alreadySkipped)
                                  }
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("You already skipped a flic today!"), message: Text("Skips are limited to 1 per day."), dismissButton: .default(Text("Got it!"))) }
                    
                    VStack {
                        if (!revealed || !submitted || (countDownTime == 0)) {
                            Spacer(minLength: DailyFlicCard.spacerHeight)
                        }
                        
                    }.onAppear(perform: {
//                        revealed = getRevealed(results: revealController)
//                        submitted = getSubmitted(results: revealController)
                        alreadySkipped = getSkipped(results: revealController)
                        countDownTime = timeInSeconds()
                        Analytics.logEvent(AnalyticsEventScreenView,
                                           parameters: [AnalyticsParameterScreenName: "Today's Flic",
                                                        AnalyticsParameterScreenClass: "Today's Flic"])
                    })
                }
            )
    }
    
    //Convert the time into seconds
    func timeInSeconds() -> Int {
        let date = Date()
        let calendar = Calendar.current
        let hoursInSeconds   = Int(calendar.component(.hour, from: date)) * 3600
        let minutesInSeconds = Int(calendar.component(.minute, from: date)) * 60
        let secondsInSeconds = Int(calendar.component(.second, from: date)) * 1
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
            fetchOptions.fetchLimit = 15000
            fetchOptions.predicate = NSPredicate(format: "mediaType == \(PHAssetMediaType.image.rawValue) AND !((mediaSubtype & \(PHAssetMediaSubtype.photoScreenshot.rawValue)) == \(PHAssetMediaSubtype.photoScreenshot.rawValue))")
            let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)

            if fetchResult.count > 0 {
                let fetched = fetchResult.count
                var index = Int.random(in: 0..<fetched)
                print(index)
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = true
                var imgHolder : UIImage = UIImage()
                while imgHolder.size == CGSize(width: 0, height: 0) {
                    PHImageManager.default().requestImage(for: fetchResult.object(at: index) as PHAsset,
                                                          targetSize: PHImageManagerMaximumSize,
                                                          contentMode: PHImageContentMode.aspectFill,
                                                          options: requestOptions, resultHandler: { (image, _) in
                        if image != nil {
                            imgHolder = image!
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
                        } else {
                            index = Int.random(in: 1..<fetched)
                        }
                    })
                    
                }
                
            }
        }
    }
}

struct RevealCard:View {
    var body:some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.white))
                .aspectRatio(9/16, contentMode: .fit)
            Image(uiImage: UIImage(named: "RevealBackground")!).resizable().aspectRatio(contentMode: .fill)
                .layoutPriority(-1).cornerRadius(10)
            VStack {
                Text("Tap to Reveal")
                    .foregroundColor(Color("PrimaryColor"))
                    .font(.largeTitle)
                Text("New photo available!")
                            .font(.subheadline)
                            .foregroundColor(Color("PrimaryColor"))
            }.frame(maxWidth: DailyFlicCard.width, maxHeight: DailyFlicCard.height, alignment: .center)
        }.clipped().cornerRadius(10).frame(width: DailyFlicCard.width, height: DailyFlicCard.height)
            
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
                .layoutPriority(-1).cornerRadius(10)
            ZStack {
                Rectangle().fill(Color(.black)).frame(width: DailyFlicCard.width, height: 100, alignment: .bottom).opacity(0.3)
                VStack {
                    Text(photoDateData, style: .date)
                        .font(.title2).foregroundColor(Color.white).frame(maxWidth: DailyFlicCard.width - 20, alignment: .leading)
                    if photoCountry != "" {
                        if photoLocality != "" && photoAdministrativeArea != "" {
                            Text(photoLocality + ", " + photoAdministrativeArea + " |  " + photoCountry)
                                .font(.headline)
                                .foregroundColor(Color.white)
                                .frame(maxWidth: DailyFlicCard.width - 20, alignment: .leading)
                        } else if photoAdministrativeArea != "" {
                            Text(photoAdministrativeArea + " |  " + photoCountry)
                                .font(.headline)
                                .foregroundColor(Color.white)
                                .frame(maxWidth: DailyFlicCard.width - 20, alignment: .leading)
                        } else if photoLocality != "" {
                            Text(photoLocality + " |  " + photoCountry)
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
    var revealController : FetchedResults<RevealController>
    @Binding var fromSubmit : Bool
    @State private var reflectionText: String = "Write reflection..."
    @State private var title: String = ""
    @State var selectedEmotion = 0
    @StateObject var historyVM = HistoryViewModel()
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .frame(width: DailyFlicCard.width, height: DailyFlicCard.height)
            .overlay(
                VStack {
                    TextField("Add Title", text: $title)
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.black)
                        .frame(maxWidth: (DailyFlicCard.width * 0.85), alignment: .center)
                        .padding(20).onTapGesture {
                            typing = true
                            Analytics.logEvent("tapped_to_add_title", parameters: nil)
                            if title == "Add Title" {
                                title = ""
                            }
                        }
                    Text("How did this image make you feel?")
                        .font(.headline)
                        .foregroundColor(Color("PrimaryColor"))
                        .frame(maxWidth: (DailyFlicCard.width * 0.85), alignment: .leading)
                    HStack {
                        EmotionScrollButtonView(selection: $selectedEmotion)
                    }.padding()
                    TextEditor(text: $reflectionText)
                        .frame(width: (DailyFlicCard.width * 0.85), height: (DailyFlicCard.height * 0.23), alignment: .center)
                        .multilineTextAlignment(.leading)
                        .opacity((reflectionText == "Write reflection...") ? 0.90 : 1)
                        .background(Color("BackgroundColor"))
                        .foregroundColor((reflectionText == "Write reflection...") ? .gray : Color.black)
                        .lineLimit(100).onAppear {
                            // put back the placeholder text if the user dismisses the keyboard without adding any text
                            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (noti) in
                                withAnimation {
                                    if reflectionText == "" {
                                        reflectionText = "Write reflection..."
                                    }
                                }
                            }
                        }.onTapGesture {
                            if typing {
                                hideKeyboard()
                            }
                            typing = true
                            if reflectionText == "Write reflection..." {
                                reflectionText = ""
                            }
                            Analytics.logEvent("tapped_to_write_reflection", parameters: nil)
                        }
                    HStack {
                        Button {
                            submit()
                            setSubmitted(revealController: revealController)
                        } label : {
                            Text("Save to History")
                                .foregroundColor(.white)
                        }
                    }.padding().background(Color("PrimaryColor")).cornerRadius(40)
                }
            ).onAppear( perform: {
                Analytics.logEvent(AnalyticsEventScreenView,
                                   parameters: [AnalyticsParameterScreenName: "Write Reflection",
                                                AnalyticsParameterScreenClass: "Today's Flic"])
                }
            )
    }
    
        
    func submit() {
        submitted = true
//        let reflection = Reflection(context: managedObjectContext)
//        reflection.text = reflectionText
//        reflection.title = title
//        reflection.date = date
//        reflection.country = photoCountry
//        reflection.administrativeArea = photoAdministrativeArea
//        reflection.locality = photoLocality
//        reflection.emotion = emotionsDictionary.first(where: { $0.value == selectedEmotion})?.key
        
        historyVM.addReflection(reflectionText: reflectionText, title: title, date: date, photoCountry: photoCountry, photoAdministrativeArea: photoAdministrativeArea, photoLocality: photoLocality, selectedEmotion: selectedEmotion, dailyImage: dailyImage)
        
        Analytics.logEvent("saved_reflection", parameters: [
//            "emotion": reflection.emotion ?? "",
            "titleLength": title.count,
            "reflectionLength": reflectionText.count,
            "country": photoCountry,
            "adminArea": photoAdministrativeArea,
            "locality": photoLocality
        ])
        
        

//        let tempImage = dailyImage
//        UIGraphicsBeginImageContext(CGSize(width:75, height: 100))
//        tempImage.draw(in: CGRect(x:0, y:0, width:75, height: 100))
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        let pngImageData  = dailyImage.pngData()
//        let thumbnailData = newImage?.pngData()
//
//        reflection.image = pngImageData
//        reflection.thumbnail = thumbnailData
//
//        PersistenceController.shared.save()
        fromSubmit = true
        self.tabSelection = 1
    }
}

func setSubmitted(revealController: FetchedResults<RevealController>) {
    @Environment(\.managedObjectContext) var managedObjectContext
    //FIRST use
    if revealController.isEmpty {
        let controller = RevealController(context: managedObjectContext)
        controller.submitted = Date()
        PersistenceController.shared.save()
    }
    //UPDATE existing revealController
    for controller in revealController {
        controller.submitted = Date()
        PersistenceController.shared.save()
    }
}

struct CountDownCard:View {
    @Binding var timeRemaining:Int
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body:some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.white))
                .aspectRatio(9/16, contentMode: .fit)
            Image(uiImage: UIImage(named: "CountdownBackground")!).resizable().aspectRatio(contentMode: .fill)
                .layoutPriority(-1).cornerRadius(10)
            VStack {
                Text("Next reveal in...")
                    .foregroundColor(Color("PrimaryColor"))
                    .font(.title)
                Text("\(timeString(time: timeRemaining))")
                            .font(.system(size: 60))
                            .fontWeight(.bold)
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
            }.frame(maxWidth: DailyFlicCard.width, maxHeight: DailyFlicCard.height, alignment: .center).navigationBarHidden(true)
        }.clipped().cornerRadius(10).frame(width: DailyFlicCard.width, height: DailyFlicCard.height)
            .onAppear(perform: {
                Analytics.logEvent(AnalyticsEventScreenView,
                                   parameters: [AnalyticsParameterScreenName: "Countdown",
                                                AnalyticsParameterScreenClass: "Today's Flic"])
            })
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
                            Analytics.logEvent("pressed_emotion", parameters: [
                                "emotion": selected
                            ])
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
            if let next = result.nextReveal {
                if (currDate > next) {
                    return false
                } else {
                    return true
                }
            }
        }
    }
    return false;
}

func getSubmitted(results: FetchedResults<RevealController>) -> Bool {
    if (!results.isEmpty) {
        for result in results {
            if let last = result.submitted {
                if Calendar.current.isDateInToday(last) {
                    return true
                } else {
                    return false
                }
            }
        }
    }
    return false;
}

func getSkipped(results: FetchedResults<RevealController>) -> Bool {
    if (!results.isEmpty) {
        for result in results {
            if let last = result.lastSkip {
                if Calendar.current.isDateInToday(last) {
                    return true
                } else {
                    return false
                }
            }
        }
    }
    return false;
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
