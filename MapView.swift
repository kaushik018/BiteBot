import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), // Default to NYC
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var showLocationError = false
    @State private var locationErrorMessage = ""
    
    private let primaryBrown = Color(red: 0.33575628219999998, green: 0.2216454944, blue: 0.029086147579999999)
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region,
                showsUserLocation: true,
                userTrackingMode: .constant(.follow))
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: centerOnUser) {
                        Image(systemName: "location.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(primaryBrown)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                            .padding()
                    }
                }
            }
        }
        .preferredColorScheme(.light)
        .alert("Location Error", isPresented: $showLocationError) {
            Button("OK", role: .cancel) { }
            Button("Settings", role: .none) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text(locationErrorMessage)
        }
        .onAppear {
            locationManager.requestLocationPermission()
        }
        .onChange(of: locationManager.location) { newLocation in
            if let location = newLocation {
                withAnimation {
                    region.center = location.coordinate
                }
            }
        }
        .onChange(of: locationManager.authorizationStatus) { status in
            switch status {
            case .denied, .restricted:
                showLocationError = true
                locationErrorMessage = "Please enable location services in Settings to see your location on the map."
            case .notDetermined:
                locationManager.requestLocationPermission()
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.startUpdatingLocation()
            @unknown default:
                break
            }
        }
    }
    
    private func centerOnUser() {
        if let location = locationManager.location {
            withAnimation {
                region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
        } else {
            showLocationError = true
            locationErrorMessage = "Unable to determine your location. Please make sure location services are enabled."
        }
    }
} 
