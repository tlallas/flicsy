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
    @State var displayImage: Bool = false
    @State var photoDate : Date = Date()
    
    var body: some View {
        VStack(spacing: 30){
            if (!displayImage) {
                Text("This is where the daily photo will pop up!")
                Button {
                        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
                            PHPhotoLibrary.requestAuthorization({(status: PHAuthorizationStatus) -> Void in ()
                            })
                        } else {
                            let fetchOptions = PHFetchOptions()
                            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                            fetchOptions.fetchLimit = 10
                            let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
                            
                            if fetchResult.count > 0 {
                                let fetched = fetchResult.count
                                let index = Int.random(in: 1..<fetched)
                                let requestOptions = PHImageRequestOptions()
                                requestOptions.isSynchronous = true
                            PHImageManager.default().requestImage(for: fetchResult.object(at: index) as PHAsset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, _) in
                                dailyImage = image!
                                displayImage = true
                                
                                
//                                photoDate = image?.creationDate ?? Date()
                                
                             
                            })
                        }
                    }
                } label : {
                    Text("Reveal Your Daily Photo")
                }
            }
            if (displayImage) {
                Image(uiImage: dailyImage)
                    .resizable()
                    .scaledToFill()
            }
        }
    }
}

struct DailyHomeView_Previews: PreviewProvider {
    static var previews: some View {
        DailyHomeView(dailyImage: UIImage())
    }
}
