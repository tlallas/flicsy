//
//  flicsyApp.swift
//  flicsy
//
//  Created by Taylor  Lallas on 4/23/22.
//

import SwiftUI

@main
struct flicsyApp: App {
    let persistentController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase
    
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
            case .inactive:
                print("Scene is inactive")
            case .active:
                print("Scene is active")
            @unknown default:
                print("Scene is default")
            }
        }
    }
}
