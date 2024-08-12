//
//  LocationManager.swift
//  Weather
//
//  Created by Suresh Reddy on 8/10/24.
//

import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    // Singleton instance
    static let shared = LocationManager()
    private var locationManager: CLLocationManager
    private var completion: ((Result<String, Error>) -> Void)?
    
    // Private initializer for Singleton pattern
    private override init() {
        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    // Request and retrieve the current city based on the user's location.
    func getCurrentCity(completion: @escaping (Result<String, Error>) -> Void) {
        self.completion = completion
        self.locationManager.startUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    // Handle location updates and reverse geocode to get the current city.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            completion?(.failure(LocationError.noLocationAvailable))
            return
        }
        
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            
            if let error = error {
                self.completion?(.failure(error))
            } else if let placemark = placemarks?.first {
                
                if let city = placemark.locality {
                    self.completion?(.success(city))
                } else {
                    self.completion?(.failure(LocationError.noCityAvailable))
                }
            } else {
                self.completion?(.failure(LocationError.noPlacemarkAvailable))
            }
        }
        self.locationManager.stopUpdatingLocation()
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        if let clErr = error as? CLError {
            switch clErr.code {
            case CLError.locationUnknown:
                completion?(.failure(LocationError.locationUnknown))
            case CLError.denied:
                completion?(.failure(LocationError.denied))
            default:
                completion?(.failure(LocationError.coreLocationError))
            }
        } else {
            debugPrint("other error:", error.localizedDescription)
            completion?(.failure(error))
        }
        completion?(.failure(error))
    }
}
