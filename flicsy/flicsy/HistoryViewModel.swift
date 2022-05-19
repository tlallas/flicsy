//
//  HistoryViewModel.swift
//  flicsy
//
//  Created by Taylor  Lallas on 5/18/22.
//

import Foundation
import CoreData
import UIKit
import SwiftUI

class HistoryViewModel : ObservableObject {
    let container: NSPersistentContainer = PersistenceController.shared.container
    @Published var reflections: [Reflection] = []
    @Published var loading : Bool = false
   
    
    init() {
        fetchReflections()
    }
    
    func fetchReflections() {
        loading = true
        let request = NSFetchRequest<Reflection>(entityName: "Reflection")
        let sort = NSSortDescriptor(keyPath: \Reflection.date, ascending: false)
        request.sortDescriptors = [sort]
        do {
            reflections = try container.viewContext.fetch(request)
            loading = false
        } catch let error {
            print("Error fetching. \(error)")
            loading = false 
        }
    }
    
    func addReflection(reflectionText: String, title: String, date: Date, photoCountry: String, photoAdministrativeArea: String, photoLocality: String, selectedEmotion: Int, dailyImage: UIImage) {
        let newRef = Reflection(context: container.viewContext)
        newRef.text = reflectionText == "Write reflection..." ? "" : reflectionText
        
        newRef.title = title
        newRef.date = date
        newRef.country = photoCountry
        newRef.administrativeArea = photoAdministrativeArea
        newRef.locality = photoLocality
        newRef.emotion = emotionsDictionary.first(where: { $0.value == selectedEmotion})?.key
        
        let tempImage = dailyImage
        UIGraphicsBeginImageContext(CGSize(width:75, height: 100))
        tempImage.draw(in: CGRect(x:0, y:0, width:75, height: 100))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let pngImageData  = dailyImage.pngData()
        let thumbnailData = newImage?.pngData()
        
        newRef.image = pngImageData
        newRef.thumbnail = thumbnailData
        saveData()
    }
    
    func saveData() {
        do {
            try container.viewContext.save()
            fetchReflections()
        } catch let error {
            print("Error saving. \(error)")
        }
    }
    

    
}
