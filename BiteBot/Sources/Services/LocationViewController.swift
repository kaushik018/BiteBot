import UIKit
import MapKit
import CoreLocation

class LocationViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    private let locationManager = CLLocationManager()
    private let regionInMeters: Double = 500
    private var restaurants: [Restaurant] = []
    private let searchRadius: CLLocationDistance = 2000 // 2km radius
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        setupMapView()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation // Highest accuracy
        locationManager.distanceFilter = kCLDistanceFilterNone // Update location as frequently as possible
        locationManager.activityType = .fitness // Optimized for walking/running accuracy
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func setupMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.showsCompass = true
        mapView.showsScale = true
    }
    
    private func centerViewOnUserLocation() {
        if let location = locationManager.location {
            let region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: regionInMeters,
                longitudinalMeters: regionInMeters
            )
            mapView.setRegion(region, animated: true)
            searchNearbyRestaurants(at: location.coordinate)
        }
    }
    
    private func searchNearbyRestaurants(at coordinate: CLLocationCoordinate2D) {
        // Clear existing annotations
        let existingAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(existingAnnotations)
        
        // Create a search request
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "restaurant"
        request.region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: searchRadius,
            longitudinalMeters: searchRadius
        )
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self,
                  let response = response else {
                print("Error searching for restaurants: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            self.restaurants = response.mapItems.map { item in
                let location = item.placemark.coordinate
                let distance = self.locationManager.location?.distance(from: CLLocation(latitude: location.latitude, longitude: location.longitude)) ?? 0
                
                return Restaurant(
                    name: item.name ?? "Unknown Restaurant",
                    cuisine: "Unknown", // We'll need to determine this from the place data
                    rating: 0.0, // We'll need to fetch this separately
                    image: "",
                    priceLevel: .moderate, // Default value
                    atmosphere: [.casual],
                    features: [],
                    openingHours: OpeningHours(days: [:]),
                    distance: distance / 1000, // Convert to kilometers
                    isOpenNow: true, // We'll need to fetch this separately
                    latitude: 41.6544,
                    longitude: -83.5361
                )
            }
            
            // Add annotations for each restaurant
            let annotations = self.restaurants.map { restaurant -> MKPointAnnotation in
                let annotation = RestaurantAnnotation(restaurant: restaurant)
                annotation.coordinate = response.mapItems[self.restaurants.firstIndex(where: { $0.name == restaurant.name }) ?? 0].placemark.coordinate
                annotation.title = restaurant.name
                annotation.subtitle = String(format: "%.1f km away", restaurant.distance)
                return annotation
            }
            
            self.mapView.addAnnotations(annotations)
        }
    }
    
    @IBAction func centerButtonTapped(_ sender: UIButton) {
        centerViewOnUserLocation()
    }
}

// MARK: - Custom Annotation
class RestaurantAnnotation: MKPointAnnotation {
    let restaurant: Restaurant
    
    init(restaurant: Restaurant) {
        self.restaurant = restaurant
        super.init()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
        case .denied, .restricted:
            // Show alert to user that location is denied
            let alert = UIAlertController(
                title: "Location Access Denied",
                message: "Please enable location access in Settings to see your location on the map.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last,
              location.horizontalAccuracy <= 20 else { // Only accept locations with accuracy within 20 meters
            return
        }
        
        // If this is the first location update, center the map
        if mapView.userLocation.location == nil {
            centerViewOnUserLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
        
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                // Handle denied error
                locationManager.stopUpdatingLocation()
            case .locationUnknown:
                // Try requesting location again after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.locationManager.startUpdatingLocation()
                }
            default:
                break
            }
        }
    }
}

// MARK: - MKMapViewDelegate
extension LocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? RestaurantAnnotation else { return nil }
        
        let identifier = "RestaurantAnnotation"
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        
        annotationView.canShowCallout = true
        annotationView.markerTintColor = UIColor(red: 0.33575628219999998, green: 0.2216454944, blue: 0.029086147579999999, alpha: 1)
        
        // Add a button to show restaurant details
        let button = UIButton(type: .detailDisclosure)
        annotationView.rightCalloutAccessoryView = button
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? RestaurantAnnotation else { return }
        
        // Present restaurant details
        let restaurant = annotation.restaurant
        // TODO: Present restaurant detail view
        print("Show details for restaurant: \(restaurant.name)")
    }
} 
