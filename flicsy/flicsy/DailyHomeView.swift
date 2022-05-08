//
//  DailyHomeView.swift
//  flicsy
//
//  Created by Taylor  Lallas on 4/23/22.
//

import SwiftUI
import PhotosUI

struct DailyHomeView: View {
    @State var dailyImage:UIImage
    @Binding var tabSelection: Int
    @State var displayImage: Bool = false
    @State var goToReflectionWritingView: Bool = false
    @State var photoDateData : Date = Date()
    @State var photoLocationData : CLLocation = CLLocation()
    @State var photoLocality : String = "" //city
    @State var photoAdministrativeArea : String = "" //state or region
    @State var photoCountry : String = ""
    
    let ceo: CLGeocoder = CLGeocoder()
    
    func reflectionPage() {
        goToReflectionWritingView = true
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack{
                    if (!displayImage) {
                        Text("This is where the daily photo will pop up!")
                        Button {
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
                                    PHImageManager.default().requestImage(for: fetchResult.object(at: index) as PHAsset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, _) in
                                        dailyImage = image!
                                        displayImage = true
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
                        } label : {
                            Text("Reveal Your Daily Photo")
                        }
                    }
                    if (displayImage) {
                        VStack {
                            HStack(alignment: .center){
                                VStack{
                                    HStack {
                                        Text(photoDateData, style: .date)
                                            .font(.title2)
                                        Spacer()
                                    }.padding(.leading)
                                    HStack {
                                        if photoLocality != "" && photoAdministrativeArea != "" {
                                            LocationHeadlineView(headlineText: photoLocality + ", " + photoAdministrativeArea)
                                        } else if photoAdministrativeArea != "" {
                                            LocationHeadlineView(headlineText: photoAdministrativeArea)
                                        } else if photoLocality != "" {
                                            LocationHeadlineView(headlineText: photoLocality)
                                        }
                                        if photoCountry != "" {
                                            Text("|  " + photoCountry)
                                                .font(.headline)
                                        }
                                        Spacer()
                                    }.padding(.leading)
                                }
                            }
                            VStack {
                                Image(uiImage: dailyImage)
                                    .resizable()
        //                            .frame(
        //                               width:UIScreen.main.bounds.width,
        //                               height:UIScreen.main.bounds.height - 170
        //                            )
        //                            .aspectRatio(contentMode: .fit)
                                    .scaledToFill()
                                VStack {
                                    Spacer()
                                    NavigationLink(destination: ReflectionWritingView(dailyImage: $dailyImage, date: $photoDateData, tabSelection: $tabSelection, country: $photoCountry, adminArea: $photoAdministrativeArea, locality: $photoLocality)) {
                                        Text("Write Reflection")
                                            .padding()
                                            .background(Color.white)
                                    }
                                }
                            }
                        }
                    }
                    Spacer(minLength: 80)
                }
            }
        }
    }
}

struct LocationHeadlineView : View {
    var headlineText : String
    var body: some View {
        Text(headlineText)
            .font(.headline)
    }
}
//
//struct DailyHomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        DailyHomeView(dailyImage: UIImage(), tabSelection: $0)
//    }
//}
