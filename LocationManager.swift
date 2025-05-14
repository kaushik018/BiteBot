import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var lastError: Error?
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Update location every 10 meters
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = false // Set to true if you need background location
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async { [weak self] in
            self?.authorizationStatus = manager.authorizationStatus
            
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                self?.startUpdatingLocation()
            case .denied, .restricted:
                self?.stopUpdatingLocation()
                self?.location = nil
            case .notDetermined:
                self?.requestLocationPermission()
            @unknown default:
                break
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async { [weak self] in
            if let location = locations.last {
                // Filter out invalid locations
                if location.horizontalAccuracy >= 0 {
                    self?.location = location
                    self?.lastError = nil
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.lastError = error
            if let error = error as? CLError {
                switch error.code {
                case .denied:
                    // Handle denied error
                    self?.stopUpdatingLocation()
                    self?.location = nil
                case .locationUnknown:
                    // Handle unknown location error
                    break
                default:
                    // Handle other errors
                    break
                }
            }
        }
    }
} 