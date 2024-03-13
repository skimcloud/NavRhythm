//
//  NavRhythmPrototypeApp.swift
//  NavRhythmPrototype
//
//  Created by Shane Kim on 2/21/24.
//

import SwiftUI

@main
struct NavRhythmPrototypeApp: App {
    @State private var showPopUp = true
    @StateObject var navigationAndHapticModel = NavigationAndHapticModel(navigationService: NavigationService(), hapticFeedbackService: HapticFeedbackService(), startAddressString: "", destinationAddressString: "", isNavigating: false)
    
    var body: some Scene {
        WindowGroup {
            ZStack{
                ContentView()
                    .environmentObject(navigationAndHapticModel)
                if showPopUp {
                    PopUpIcon()
                    
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // makes it disappear after 2 secs
                                showPopUp = false
                                
                            }
                        }
                }
            }
        }
    }
}
