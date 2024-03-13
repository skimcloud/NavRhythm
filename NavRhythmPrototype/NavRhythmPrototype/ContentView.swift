import SwiftUI
import MapKit

struct ContentView: View {
    @EnvironmentObject var navigationAndHapticModel: NavigationAndHapticModel
    @State var locationManager = LocationManager()
    @State private var searchResults: [MKLocalSearchCompletion] = []

    // Create a timer that fires every second
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            VStack {
                HStack {
                    VStack {
                        if !navigationAndHapticModel.isNavigating {
                            SearchBarView(
                                startInput: $navigationAndHapticModel.startAddressString,
                                destinationInput: $navigationAndHapticModel.destinationAddressString,
                                searchPopulatedResults: $searchResults
                            )
                        }
                    }
                }
                .padding([.leading, .trailing])
                if !navigationAndHapticModel.isNavigating {
                    Button {
                        navigationAndHapticModel.isNavigating = true
                        Task {
                            try? await navigationAndHapticModel.getRouteInformation()
                        }
                    } label: {
                        Text("Start Navigation").bold()
                            .frame(width: UIScreen.main.bounds.width * 0.5)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(navigationAndHapticModel.startAddressString.isEmpty || navigationAndHapticModel.destinationAddressString.isEmpty)
                    Spacer().frame(height: 10) 
                }
            }
            ZStack{
                Map(position: $navigationAndHapticModel.cameraPosition) {
                    if let route = navigationAndHapticModel.currentRoute {
                        MapPolyline(route)
                            .stroke(.blue, lineWidth: 5)
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                    MapPitchToggle()
                }
                .onAppear {
                    CLLocationManager().requestWhenInUseAuthorization()
                }
                .onReceive(timer) { _ in
                    if navigationAndHapticModel.isNavigating, let userLocation = locationManager.location {
                        navigationAndHapticModel.userCoordinates = userLocation.coordinate
                        print("USER COORDINATES UPDATED \(navigationAndHapticModel.userCoordinates)")
                        navigationAndHapticModel.updateNavigation()
                    } else {
                        print("LOCATION COULD NOT BE FOUND!")
                    }
                }
                VibrationView()
            }
        }
    }
}

#Preview {
    ContentView()
}
