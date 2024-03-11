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
            self.currentRoute = try await navigationService.getShortestRoute(startAddressString: self.startAddressString, destinationAddressString: self.destinationAddressString)
            self.routeCoordinates = currentRoute!.polyline.coordinates
            if let steps = currentRoute?.steps {
                for eachStep in steps {
                    self.maneuverCoordinates.append(eachStep.polyline.coordinate)
                    self.maneuverType.append(eachStep.instructions)
                }
            }
            
        } catch {
            print("Failed to get the shortest route: \(error)")
            throw error
        }
    }
    
    func updateNavigation() {
        self.navigationUpdate = navigationService.getDistanceToManeuver(position: self.cameraPosition, maneuverCoordinates: self.maneuverCoordinates, routeCoordinates: self.routeCoordinates, maneuverCoordinateIndex: self.maneuverCoordinateIndex, routeCoordinateIndex: self.routeCoordinateIndex)
        self.distanceToNextManeuver = self.navigationUpdate!.distanceToManeuver
        self.hapticFeedbackService.sendManeuverFeedback(maneuverType: maneuverType[maneuverCoordinateIndex], distance: distanceToNextManeuver)
        self.maneuverCoordinateIndex = self.navigationUpdate!.maneuverCoordinateIndex
        self.routeCoordinateIndex = self.navigationUpdate!.routeCoordinateIndex
    }
}
