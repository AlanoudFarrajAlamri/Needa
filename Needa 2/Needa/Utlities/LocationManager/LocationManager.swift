//
//  LocationManager.swift
//  Needa
//
//  Created by Qazi Ammar Arshad on 11/10/2024.
//
import Foundation
import CoreLocation
import MapKit

// We defined LocationManager class to manage and track user location using CoreLocation and MapKit.
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    private let manager = CLLocationManager() // Instance of CLLocationManager to handle location updates
    
    @Published var userLocation: CLLocation?
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        latitudinalMeters: 1000,
        longitudinalMeters: 1000
    )
    
    override init() {
        super.init()
        manager.delegate = self // Set the delegate to self to receive location updates
        manager.desiredAccuracy = kCLLocationAccuracyBest // Set the desired accuracy for location updates
        manager.requestWhenInUseAuthorization() // Request user's permission for location access when app is in use
        manager.startUpdatingLocation() // Start updating the location
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()  // Request authorization again if needed
        manager.startUpdatingLocation()
    }
    
    func fetchDirections(destination: CLLocation, completion: @escaping (MKRoute?) -> Void) {
        guard let sourceLocation = userLocation else {
            print("Source location is undefined.") // Print error if source location is not available
            completion(nil)
            return
        }
        
        // Placemark objects for the source and destination coordinates.
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation.coordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destination.coordinate)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlacemark)
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = .automobile // Set the transport type to automobile
        
        // Calculating the directions
        let directions = MKDirections(request: directionRequest)
        directions.calculate { response, error in
            DispatchQueue.main.async {
                if let route = response?.routes.first {
                    completion(route) // Return the first route if available
                } else {
                    print("Failed to fetch directions: \(error?.localizedDescription ?? "Unknown error")")
                    completion(nil)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return } // Guard to make sure location data is available
        print("New user location: \(newLocation)") // Print the new user location
        
        DispatchQueue.main.async {
            self.userLocation = newLocation // Update the current user location
            self.region = MKCoordinateRegion(
                center: newLocation.coordinate,
                latitudinalMeters: 1000,
                longitudinalMeters: 1000
            ) // Update the map region to center around the new location
            self.region.center = newLocation.coordinate // Adjust the center of the region to the new location
        }
    }
    
    // Delegate method called when an error occurs during location updates
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error updating location: \(error.localizedDescription)") // Print error message if there is an error during location updates
    }
}
