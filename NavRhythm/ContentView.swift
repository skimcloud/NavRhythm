//
//  ContentView.swift
//  NavRhythm
//
//  Created by Shane Kim on 2/20/24.
//


import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    @State private var selectedResult: MKMapItem?
    @State private var route: MKRoute?
    let locationManager = CLLocationManager()
    
    private let startingPoint = CLLocationCoordinate2D(
        latitude: 38.549671,
        longitude: -121.720299
    )
    
    private let destinationCoordinates = CLLocationCoordinate2D(
        latitude: 38.539910,
        longitude: -121.752250
    )
    
    var body: some View {
        Text("NavRhythm")
        Map(selection: $selectedResult) {
            // Adding the marker for the starting point
            UserAnnotation()
            Marker("Start", coordinate: self.startingPoint)
            Marker("End", coordinate: self.destinationCoordinates)
            
            // Show the route if it is available
            if let route {
                MapPolyline(route)
                    .stroke(.blue, lineWidth: 5)
            }
        }
        .onChange(of: selectedResult){
            getDirections()
        }
        .onAppear {
            self.selectedResult = MKMapItem(placemark: MKPlacemark(coordinate: self.destinationCoordinates))
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func getDirections() {
        self.route = nil
        
        // Check if there is a selected result
        guard let selectedResult else { return }
        
        // Create and configure the request
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: self.startingPoint))
        request.destination = self.selectedResult
        
        // Get the directions based on the request
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
