import SwiftUI
import MapKit

struct ContentView: View {
    @EnvironmentObject var navigationAndHapticModel: NavigationAndHapticModel
    @State private var searchResults: [MKLocalSearchCompletion] = []
    
    // Create a timer that fires every second
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

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
                }
            }
            
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
                if navigationAndHapticModel.isNavigating {
                    // This code executes every second while navigation is active
                    navigationAndHapticModel.updateNavigation()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
