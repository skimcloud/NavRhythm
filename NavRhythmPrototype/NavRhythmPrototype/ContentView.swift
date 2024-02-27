//
//  ContentView.swift
//  NavRhythmPrototype
//
//  Created by Shane Kim on 2/21/24.
//

import SwiftUI
import MapKit

public extension MKMultiPoint {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid,
                                              count: pointCount)

        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))

        return coords
    }
}

struct ContentView: View {
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State var startAddressString: String = ""
    @State var destinationAddressString: String = ""
    @State private var selectedResult: MKMapItem?
    @State private var route: MKRoute?
    
    @State private var startingPoint = CLLocationCoordinate2D(
        latitude: 38.539554,
        longitude: -121.749565
    )
    
    @State private var destinationPoint = CLLocationCoordinate2D(
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
                Marker("End", coordinate: self.destinationPoint)
                
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
                self.selectedResult = MKMapItem(placemark: MKPlacemark(coordinate: self.destinationPoint))
            }
        }
    }
    
    func startNavigation() {
        Task {
            let startPlacemarkArray = try? await CLGeocoder().geocodeAddressString(startAddressString)
            let destinationPlacemarkArray = try? await CLGeocoder().geocodeAddressString(destinationAddressString)
            self.startingPoint.latitude = (startPlacemarkArray?[0].location?.coordinate.latitude ??  0.0) as Double
            self.startingPoint.longitude = (startPlacemarkArray?[0].location?.coordinate.longitude ?? 0.0) as Double
            self.destinationPoint.latitude = (destinationPlacemarkArray?[0].location?.coordinate.latitude ?? 0.0) as Double
            self.destinationPoint.longitude = (destinationPlacemarkArray?[0].location?.coordinate.longitude ?? 0.0) as Double
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
            print(route?.polyline.coordinates ?? 0.0)
            
            // TODO: have a global maneuver only coordinate array (eachStep.polyline.coordinate)
            // TODO: global variable to indicate which maneuver (index to global maneuver array)
            // TODO: global ALL step coordinate array for drawRouteFromNextStepCoordinate()
                // use route.coordinates (class extended above to support this)
            
            if let steps = route?.steps {
                for eachStep in steps {
                    print(eachStep.polyline.coordinate)
                    print(eachStep.instructions)
                    print(eachStep.distance)
                }
            }

        }
    }
    
    func getDistanceToManeuver() { // TODO: calculate distance to next maneuver
        
        // compare current user coordinates with maneuver coordinates stored in our global manever only coordinate array create above in line 115
        
    }
    
    // Based on the output of getDistanceToManeuver(), we will increase the vibration frequency and strength
    
    func drawRouteFromNextStepCoordinate() { // TODO: once a route coordinate is passed delete it so that the poly line is redrawn
        
        // Compare current user coordinates with first coordinates in array, if it's at a certain threshold above or below it, delete it
        
        // Polyline will be automatically redrawn (hopefully)
        
    }
}

#Preview {
    ContentView(startAddressString: "", destinationAddressString: "")
}
