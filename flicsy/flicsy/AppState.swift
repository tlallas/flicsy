//
//  AppState.swift
//  flicsy
//
//  Created by Taylor  Lallas on 5/12/22.
//

import Foundation
import UIKit
import SwiftUI

class AppState: ObservableObject {
    @Published var isActive = true

    private var observers = [NSObjectProtocol]()

    init() {
        observers.append(
            NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
                self.isActive = true
            }
        )
        observers.append(
            NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { _ in
                self.isActive = false
            }
        )
    }
    
    deinit {
        observers.forEach(NotificationCenter.default.removeObserver)
    }
}
