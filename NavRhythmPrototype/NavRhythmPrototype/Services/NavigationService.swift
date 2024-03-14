//
//  NavigationService.swift
//  NavRhythmPrototype
//
//  Created by Shane Kim on 3/6/24.
//

import Foundation
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

final class NavigationService: ObservableObject {
    
    func getShortestRoute(startAddressString: String, destinationAddressString: String) async throws -> MKRoute {
        let startPlacemarkArray = try await CLGeocoder().geocodeAddressString(startAddressString)
        let destinationPlacemarkArray = try await CLGeocoder().geocodeAddressString(destinationAddressString)
        let startCoordinates = startPlacemarkArray.first?.location?.coordinate
        let endCoordinates = destinationPlacemarkArray.first?.location?.coordinate
        let route = try await getDirections(startCoordinates: startCoordinates!, endCoordinates: endCoordinates!)
        return route
    }

    
    func getDirections(startCoordinates: CLLocationCoordinate2D, endCoordinates: CLLocationCoordinate2D) async throws -> MKRoute {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startCoordinates))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: endCoordinates))
        request.transportType = .walking
        let directions = MKDirections(request: request)
        let response = try? await directions.calculate()
        let route = response?.routes.first
        printRouteCoordinates(route: route!)
        return route!
    }
    
    func printRouteCoordinates(route: MKRoute) {
        let routeCoordinates = route.polyline.coordinates
        var count = 0
        for c in routeCoordinates {
            print("Route Coordinate \(count): \(c)")
            count += 1
        }
        
        count = 0
        let steps = route.steps
        for eachStep in steps {
            print("Maneuver Coordinate \(count): \(eachStep.polyline.coordinate)")
            print(eachStep.instructions)
            print(eachStep.distance)
            count += 1
        }
    }
     
    func getUserLocation(position: MapCameraPosition) -> CLLocationCoordinate2D {
        let userCoordinates = (position.rect?.origin.coordinate)!
        return userCoordinates
    }
    
    func getDistanceToManeuver(userCoordinates: CLLocationCoordinate2D, maneuverCoordinates: [CLLocationCoordinate2D], routeCoordinates: [CLLocationCoordinate2D], maneuverCoordinateIndex: Int, routeCoordinateIndex: Int) -> NavigationUpdate {
        //let userLocation = getUserLocation(position: position)
        let userCLLocation = CLLocation(latitude: userCoordinates.latitude, longitude: userCoordinates.longitude)

        // Ensure maneuverCoordinates index is valid
        guard maneuverCoordinates.indices.contains(maneuverCoordinateIndex) else {
            return NavigationUpdate(maneuverCoordinateIndex: maneuverCoordinateIndex, routeCoordinateIndex: routeCoordinateIndex, distanceToManeuver: 0.0)
        }
        let nextManeuverLocation = maneuverCoordinates[maneuverCoordinateIndex]

        var totalDistanceToManeuver: Double = 0.0
        var closestRoutePointIndex = routeCoordinateIndex
        var minimumDistance = Double.greatestFiniteMagnitude

        for index in routeCoordinateIndex..<routeCoordinates.count {
            let coordinate = routeCoordinates[index]
            let distance = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude).distance(from: userCLLocation)
            if distance < minimumDistance {
                minimumDistance = distance
                closestRoutePointIndex = index
            }
        }

        var updatedManeuverCoordinateIndex = maneuverCoordinateIndex

        for index in closestRoutePointIndex..<routeCoordinates.count {
            if routeCoordinates[index].latitude == nextManeuverLocation.latitude && routeCoordinates[index].longitude == nextManeuverLocation.longitude {
                updatedManeuverCoordinateIndex = index
                break
            }
            if index + 1 < routeCoordinates.count {
                let startPoint = CLLocation(latitude: routeCoordinates[index].latitude, longitude: routeCoordinates[index].longitude)
                let endPoint = CLLocation(latitude: routeCoordinates[index + 1].latitude, longitude: routeCoordinates[index + 1].longitude)
                totalDistanceToManeuver += startPoint.distance(from: endPoint)
            }
        }

        return NavigationUpdate(maneuverCoordinateIndex: updatedManeuverCoordinateIndex, routeCoordinateIndex: closestRoutePointIndex, distanceToManeuver: totalDistanceToManeuver)
    }

}
