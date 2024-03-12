//
//  NavigationAndHapticModel.swift
//  NavRhythmPrototype
//
//  Created by Shane Kim on 3/10/24.
//

import Foundation
import MapKit
import SwiftUI

final class NavigationAndHapticModel: ObservableObject {
    @Published var currentRoute: MKRoute?
    @Published var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @Published var startAddressString: String = ""
    @Published var destinationAddressString: String = ""
    @Published var selectedResult: MKMapItem?
    @Published var isNavigating = false
    @Published var route: MKRoute?
    @Published var maneuverCoordinates: [CLLocationCoordinate2D] = []
    @Published var routeCoordinates: [CLLocationCoordinate2D] = []
    @Published var maneuverType: [String] = []
    @Published var maneuverCoordinateIndex: Int = 0
    @Published var routeCoordinateIndex: Int = 0
    @Published var userCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @Published var searchResults: [MKLocalSearchCompletion] = []
    @Published var distanceToNextManeuver = 0.0
    @Published var navigationUpdate: NavigationUpdate?
    
    private var navigationService: NavigationService
    private var hapticFeedbackService: HapticFeedbackService
    
    init (
        navigationService: NavigationService,
        hapticFeedbackService: HapticFeedbackService,
        startAddressString: String,
        destinationAddressString: String,
        isNavigating: Bool
    ) {
        self.navigationService = navigationService
        self.hapticFeedbackService = hapticFeedbackService
        self.startAddressString = startAddressString
        self.destinationAddressString = destinationAddressString
        self.isNavigating = isNavigating
    }
    
    func setStartAddressString(newStartAddressString: String) {
        self.startAddressString = newStartAddressString
    }
    
    func setDestinationAddressString(newDestinationAddressString: String) {
        self.destinationAddressString = newDestinationAddressString
    }
    
    func getRouteInformation() async throws {
        do {
            let route = try await navigationService.getShortestRoute(startAddressString: self.startAddressString, destinationAddressString: self.destinationAddressString)
            DispatchQueue.main.async {
                self.currentRoute = route
                self.routeCoordinates = route.polyline.coordinates
                self.maneuverCoordinates = route.steps.map { $0.polyline.coordinate }
                self.maneuverType = route.steps.map { $0.instructions }
            }
        } catch {
            print("Failed to get the shortest route: \(error)")
            throw error
        }
    }
    
    func updateNavigation() {
        DispatchQueue.main.async {
            let navigationUpdate = self.navigationService.getDistanceToManeuver(userCoordinates: self.userCoordinates, maneuverCoordinates: self.maneuverCoordinates, routeCoordinates: self.routeCoordinates, maneuverCoordinateIndex: self.maneuverCoordinateIndex, routeCoordinateIndex: self.routeCoordinateIndex)
            
            self.navigationUpdate = navigationUpdate
            self.distanceToNextManeuver = navigationUpdate.distanceToManeuver
            self.maneuverCoordinateIndex = navigationUpdate.maneuverCoordinateIndex
            self.routeCoordinateIndex = navigationUpdate.routeCoordinateIndex
            self.hapticFeedbackService.sendManeuverFeedback(maneuverType: self.maneuverType[self.maneuverCoordinateIndex], distance: self.distanceToNextManeuver)
        }
    }


}
