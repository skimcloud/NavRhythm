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
    @State private var flag = false
    @State private var route: MKRoute?
    @State private var maneuverCoordinates: [CLLocationCoordinate2D] = [] // GLOBAL MANEUVER COORDINATES ARRAY
    @State private var routeCoordinates: [CLLocationCoordinate2D] = [] // GLOBAL ROUTE POLYLINE COORDINATES ARRAY
    @State private var maneuverCoordinateIndex: Int = 0
    @State private var routeCoordinateIndex: Int = 0
    @State private var userCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @State private var searchResults: [MKLocalSearchCompletion] = []
    
    
    
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
            VStack{
                HStack {
                    VStack {
                        if  !flag {
                            SearchBarView(startInput: $startAddressString, destinationInput: $destinationAddressString, searchPopulatedResults: $searchResults)
                        }
                
                    }

                }
                .padding([.leading, .trailing])
                if !flag { // removes search view and begins navigation view
                    Button {
                        flag = true
                        startNavigation()
                    } label: {
                        Text("Start Navigation").bold()
                            .frame(width: UIScreen.main.bounds.width * 0.5)
                    }
                    .buttonStyle(.borderedProminent) // disables the button until all inputs are populated
                    .disabled(startAddressString.isEmpty || destinationAddressString.isEmpty)
                }
          
            }

            
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
        
       // guard let selectedResult else { return }
        
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
            
            // TODO: have a global maneuver only coordinate array (eachStep.polyline.coordinate) DONE
            // TODO: global variable to indicate which maneuver (index to global maneuverCoordinates array) DONE
            // TODO: global ALL step coordinate array for drawRouteFromNextStepCoordinate() DONE
                // use route.coordinates (class extended above to support this)
            // TODO: global variable to indicate which route (index to global routeCoordinates array) DONE
            
            routeCoordinates = route!.polyline.coordinates // GLOBAL ROUTE POLYLINE COORDINATES ARRAY
            
            
            var count = 0
            for c in routeCoordinates {
                print("Route Coordinate \(count): \(c)")
                count += 1
            }
            
            
            if let steps = route?.steps {
                for eachStep in steps {
                    maneuverCoordinates.append(eachStep.polyline.coordinate) // GLOBAL MANEUVER COORDINATES ARRAY
                    print(eachStep.polyline.coordinate)
                    print(eachStep.instructions)
                    print(eachStep.distance)
                }
            }
        }
    }
    
    func getUserLocation() -> CLLocationCoordinate2D {
        self.userCoordinates = (position.rect?.origin.coordinate)!
        return userCoordinates
    }
    
    
    // Based on the output of getDistanceToManeuver(), we will increase the vibration frequency and strength
    func getDistanceToManeuver() { // TODO: calculate distance to next maneuver
        /*
        getDistanceToManeuver()

        In order to calculate distance from current maneuver, find out which coordinate along the route we are on, and then calculate distance for all points leading up to the maneuver coordinate to see our distance from it

        -> Get user location
        -> Loop through Route coordinates and check which value is closest to it
        -> From that closest coordinate we keep iterating through the route coordinates and sum up the distances from each point
        -> Distance Text object shown in view to keep track
         
         Update route coordinate index to progress along the route
         
         */
    }
}

#Preview {
    ContentView(startAddressString: "", destinationAddressString: "")
}




