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
    @State var startAddressString: String = "625 Cantrill Drive, Davis, CA 95618"
    @State var destinationAddressString: String = "1 Shields Avenue, Davis, CA 95616"
    @State private var selectedResult: MKMapItem?
    @State private var route: MKRoute?
    
    @State private var startingPoint = CLLocationCoordinate2D(
        latitude: 38.539554,
        longitude: -121.749565
    )
    
    @State private var destinationCoordinates = CLLocationCoordinate2D(
        latitude: 38.54968227765121,
        longitude: -121.72088700348498
    )
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    TextField("Start", text: $startAddressString)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(5)
                    TextField("Destination", text: $destinationAddressString)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(5)
                }
                Button {
                    startNavigation()
                } label: {
                    Text("Start Navigation").bold()
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding([.leading, .trailing])
            
            Spacer()
            
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
    }
    
    func startNavigation() {
        Task {
            let startPlacemarkArray = try? await CLGeocoder().geocodeAddressString(startAddressString)
            let destinationPlacemarkArray = try? await CLGeocoder().geocodeAddressString(startAddressString)
            startingPoint.latitude = (startPlacemarkArray?[0].location?.coordinate.latitude ??  0.0) as Double
            startingPoint.longitude = (startPlacemarkArray?[0].location?.coordinate.longitude ?? 0.0) as Double
            destinationCoordinates.latitude = (destinationPlacemarkArray?[0].location?.coordinate.latitude ?? 0.0) as Double
            destinationCoordinates.longitude = (destinationPlacemarkArray?[0].location?.coordinate.longitude ?? 0.0) as Double
            getDirections()
        }
    }
    
    func getDirections() {
        self.route = nil
        
        guard let selectedResult else { return }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: self.startingPoint))
        request.destination = self.selectedResult

        Task {
            let placesArray = try? await CLGeocoder().geocodeAddressString("1008 Lancer Dr, San Jose, CA 95129")
            print("Latitude:", placesArray?[0].location?.coordinate.latitude as Any)
            print("Longitude:", placesArray?[0].location?.coordinate.longitude as Any)
            let directions = MKDirections(request: request)
            let response = try? await directions.calculate()
            route = response?.routes.first
        }
    }
}

#Preview {
    ContentView(startAddressString: "", destinationAddressString: "")
}
