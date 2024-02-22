//
//  ContentView.swift
//  NavRhythmPrototype
//
//  Created by Shane Kim on 2/21/24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        Map (position: $position) {
            
        }
        .mapControls {
            MapUserLocationButton()
            MapPitchToggle()
        }
        .onAppear {
            CLLocationManager().requestWhenInUseAuthorization()
        }
    }
}

#Preview {
    ContentView()
}
