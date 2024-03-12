//
//  NavRhythmPrototypeApp.swift
//  NavRhythmPrototype
//
//  Created by Shane Kim on 2/21/24.
//

import SwiftUI

@main
struct NavRhythmPrototypeApp: App {
    @StateObject var navigationAndHapticModel = NavigationAndHapticModel(navigationService: NavigationService(), hapticFeedbackService: HapticFeedbackService(), startAddressString: "", destinationAddressString: "", isNavigating: false)
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navigationAndHapticModel)
        }
    }
}
