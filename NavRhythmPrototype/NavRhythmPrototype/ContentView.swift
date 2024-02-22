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
    @State private var selectedResult: MKMapItem?
    @State private var route: MKRoute?
    let locationManager = CLLocationManager()
    
    @State private var startingPoint = CLLocationCoordinate2D(
        latitude: 38.539554,
        longitude: -121.749565
    )
    
    @State private var destinationCoordinates = CLLocationCoordinate2D(
        latitude: 38.54968227765121,
        longitude: -121.72088700348498
    )
    
    var body: some View {
        Map (position: $position, selection: $selectedResult) {
            Marker("Start", coordinate: self.startingPoint)
            Marker("End", coordinate: self.destinationCoordinates)
            
            if let route {
                MapPolyline(route)
                    .stroke(.blue, lineWidth: 5)
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapPitchToggle()
        }
        .onChange(of: selectedResult){
            getDirections()
        }
        .onAppear {
            CLLocationManager().requestWhenInUseAuthorization()
            self.selectedResult = MKMapItem(placemark: MKPlacemark(coordinate: self.destinationCoordinates))
        }
    }
    
    
    func getDirections() {
        self.route = nil
        
        guard let selectedResult else { return }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: self.startingPoint))
        request.destination = self.selectedResult

        Task {
            let directions = MKDirections(request: request)
            let response = try? await directions.calculate()
            route = response?.routes.first
        }
    }
}

#Preview {
    ContentView()
}
