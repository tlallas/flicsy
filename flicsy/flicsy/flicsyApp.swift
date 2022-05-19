//
//  flicsyApp.swift
//  flicsy
//
//  Created by Taylor  Lallas on 4/23/22.
//

import SwiftUI
import UIKit
import PhotosUI
import Foundation
import FirebaseCore
import FirebaseAnalytics

@main
struct flicsyApp: App {
    let persistentController = PersistenceController.shared
    let hvm = HistoryViewModel()
    @Environment(\.scenePhase) var scenePhase
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate NOT IN USE
    
    init () {
        FirebaseApp.configure()
        let user = UUID()
        Analytics.setUserID(user.uuidString) //track events according to user
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistentController.container.viewContext)
        }
        .onChange(of: scenePhase) { (newScenePhase) in
            switch newScenePhase {
            case .background:
                print("Scene is in background")
                persistentController.save()
                hvm.fetchReflections()
            case .inactive:
                print("Scene is inactive")
                hvm.fetchReflections()
            case .active:
                print("Scene is active")
                hvm.fetchReflections()
            @unknown default:
                print("Scene is default")
            }
        }
    }

}


//DOES NOT WORK
////create a class to use as your app's delegate
//class AppDelegate: NSObject, UIApplicationDelegate {
//    @Environment(\.managedObjectContext) var managedObjectContext
//    @FetchRequest(entity: RevealController.entity(),
//                  sortDescriptors: [])
//    var revealController : FetchedResults<RevealController>
//
//    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        // Insert code here to initialize your application
//    }
//
//    func applicationWillTerminate(_ aNotification: Notification) {
//        // Insert code here to tear down your application
//        //FIRST use
//        if revealController.isEmpty {
//            let controller = RevealController(context: managedObjectContext)
//            controller.submitted = Date()
//            PersistenceController.shared.save()
//        }
//        //UPDATE existing revealController
//        for controller in revealController {
//            controller.submitted = Date()
//            PersistenceController.shared.save()
//        }
//
//    }
//
//    //...add any other NSApplicationDelegate methods you need to use
//}
