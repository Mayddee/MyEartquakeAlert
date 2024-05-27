//
//  MapView.swift
//  My EartquakeAlert
//
//  Created by Амангелди Мадина on 08.05.2024.
//

import SwiftUI
import MapKit
import CoreLocation

struct Quake: Identifiable {
    let id = UUID()
    let location: CLLocationCoordinate2D
    let magnitude: Double
    let time: Date
}


class EarthquakeManager: ObservableObject {
    @Published var earthquakeAnnotations: [EarthquakeAnnotation] = []
    @Published var evacuationAnnotations: [PlaceAnnotation] = []


    func fetchEarthquakes() {
        guard let url = URL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson") else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                print("No earthquake data")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let earthquakeData = try decoder.decode(EarthquakeData.self, from: data)
                DispatchQueue.main.async {
                    self?.self.earthquakeAnnotations = earthquakeData.features.compactMap { feature in
//                        guard let coordinates = feature.geometry.coordinates else {
//                                return nil // Если координаты не определены, возвращаем nil
//                            }
//                            guard coordinates.count >= 2 else {
//                                return nil // Если координаты не содержат как минимум 2 элемента, возвращаем nil
//                            }
                        guard let coordinates = feature.geometry.coordinates, coordinates.count >= 2 else { return nil }

//                        let location = CLLocationCoordinate2D(latitude: coordinates[1], longitude: coordinates[0])
                        let coordinate = CLLocationCoordinate2D(latitude: coordinates[1], longitude: coordinates[0])

                        let place = feature.properties.place
                        let magnitude = feature.properties.mag
//                        return Quake(location: location, magnitude: feature.properties.mag, time: Date(timeIntervalSince1970: feature.properties.time))
                        return EarthquakeAnnotation(coordinate: coordinate, place: place, magnitude: magnitude)

                    }
                }
            } catch {
                print("Error decoding earthquake data: \(error)")
            }
        }
        
        task.resume()
    }
}




extension Geometry {
    var coordinate: CLLocationCoordinate2D? {
        guard let coordinates = coordinates, coordinates.count >= 2 else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: coordinates[1], longitude: coordinates[0])
    }
}

extension Earthquake: Identifiable {
    var coordinate: CLLocationCoordinate2D? {
        geometry.coordinate
    }
}
class PlaceAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?

    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}

class EarthquakeAnnotation: NSObject, Identifiable, MKAnnotation {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
    var place: String
    var magnitude: Double
    
    init(coordinate: CLLocationCoordinate2D, place: String, magnitude: Double) {
           self.coordinate = coordinate
           self.place = place
           self.magnitude = magnitude
       }
    
}

enum MapDetails {
    static let startingLocation = CLLocationCoordinate2D(latitude: 43.28703147843566, longitude: 77.00432980184375)
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
}

struct MapView: UIViewRepresentable {
    typealias UIViewType = MKMapView
    let almatyCoordinate = CLLocationCoordinate2D(latitude: 43.2389, longitude: 76.8897)
    @Binding var evacuationAnnotations: [PlaceAnnotation]
//    let earthquakes: [Quake]
    @Binding var earthquakeAnnotations: [EarthquakeAnnotation]




    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
//        mapView.region = MKCoordinateRegion(center: almatyCoordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
//                mapView.addAnnotations(recyclingLocations) // Add recycling locations as annotations
        mapView.delegate = context.coordinator

        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeAnnotations(mapView.annotations)
//        mapView.addAnnotations(recyclingLocations)
        mapView.addAnnotations(evacuationAnnotations)

        mapView.addAnnotations(earthquakeAnnotations)


     }
    func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
    class Coordinator: NSObject, MKMapViewDelegate {
            var parent: MapView

            init(_ parent: MapView) {
                self.parent = parent
            }

            func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//                guard let annotation = annotation as? EarthquakeAnnotation else { return nil }
//
//                let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "quakeAnnotation")
//                annotationView.markerTintColor = .red
//                annotationView.glyphText = "\(annotation.magnitude)"
//                return annotationView
                
                
                
                if let earthquakeAnnotation = annotation as? EarthquakeAnnotation {
                                let annotationView = MKMarkerAnnotationView(annotation: earthquakeAnnotation, reuseIdentifier: "quakeAnnotation")
                                annotationView.markerTintColor = .red
                                annotationView.glyphText = "\(earthquakeAnnotation.magnitude)"
                                return annotationView
                            } else if let evacuationAnnotation = annotation as? PlaceAnnotation {
                                let annotationView = MKMarkerAnnotationView(annotation: evacuationAnnotation, reuseIdentifier: "evacuationAnnotation")
                                annotationView.markerTintColor = .green
                                annotationView.glyphImage = UIImage(systemName: "house")
                                return annotationView
                            }
                            return nil
            }
        }
    

}
struct EarthquakesMapView: View {
    @State private var earthquakeData: EarthquakeData?
    @StateObject private var viewModel = MapViewModel()
    @State private var earthquakes: [Earthquake] = []
    //    @StateObject private var vModel = ViewModel()
    @ObservedObject var earthquakeManager = EarthquakeManager()
    
    @State private var evacuationLocations: [PlaceAnnotation] = [
        PlaceAnnotation(coordinate: CLLocationCoordinate2D(latitude: 43.3025, longitude: 76.9195), title: "Evacuating Place 1", subtitle: "Serikov St 61, Almaty 050000"),
        PlaceAnnotation(coordinate: CLLocationCoordinate2D(latitude: 43.2521, longitude: 76.8845), title: "Evacuating Place 2", subtitle: "Secondary recycling location"),
        PlaceAnnotation(coordinate: CLLocationCoordinate2D(latitude: 43.2578, longitude: 76.8845), title: "Evacuating Place 3", subtitle: "Secondary recycling location"),
        PlaceAnnotation(coordinate: CLLocationCoordinate2D(latitude: 43.2389, longitude: 76.8897), title: "Evacuating Place 4", subtitle: "Main recycling location"),
        PlaceAnnotation(coordinate: CLLocationCoordinate2D(latitude: 43.2534, longitude: 76.8845), title: "Evacuating Place 5", subtitle: "Secondary recycling location"),
        PlaceAnnotation(coordinate: CLLocationCoordinate2D(latitude: 43.2354, longitude: 76.9322), title: "Evacuating Place 6", subtitle: "City outskirts recycling location")]
    
    
    @State private var showEarthquakes = false
    @State private var showEvacuationPlaces = false
    
    
    
    
    var body: some View {
        
        
        //        VStack {
        //            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, userTrackingMode: .constant(.follow), annotationItems: earthquakeAnnotations) { annotation in
        //                MapMarker(coordinate: annotation.coordinate)
        //            }
        //                .ignoresSafeArea()
        //                .accentColor(Color(.systemPink))
        //                .onAppear {
        //                    fetchEarthquakeData()
        //                    viewModel.checkIfLocationServicesIsEnabled()
        //                }
        VStack {
            
            
//            Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
//                .ignoresSafeArea()
//                .accentColor(Color(.systemPink))
//                .onAppear {
//                    viewModel.checkIfLocationServicesIsEnabled()
//                }
            
            
            
            
            //                MapView(recyclingLocations: recyclingLocations)
            //                                .tag("Map")
            //                                .tabItem {
            //                                    Image(systemName: "map.fill")
            //                                    Text("Map")
            //                                }
            MapView(evacuationAnnotations: $evacuationLocations, earthquakeAnnotations: $earthquakeManager.earthquakeAnnotations)
                .onAppear {
                    earthquakeManager.fetchEarthquakes()
                }
            
            
            
        }
        
        
//        Button(action: {
//            
//        }, label : {
//            Text("Show directions")
//        })
//        .padding(5)
    }
    
}

final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate /*In case user can change location permissions*/ {
    
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: MapDetails.startingLocation.latitude, longitude: MapDetails.startingLocation.longitude), span: MKCoordinateSpan(latitudeDelta: MapDetails.defaultSpan.latitudeDelta, longitudeDelta: MapDetails.defaultSpan.longitudeDelta))
    
    var locationManager: CLLocationManager?
    
    
    
    func checkIfLocationServicesIsEnabled(){
        if CLLocationManager.locationServicesEnabled(){
            locationManager = CLLocationManager()
//            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
//            checkLocationAuthorization()
            locationManager?.delegate = self
        }else {
            print("Show an alert letting them know this is off and to go turn it on")
        }
    }
    
    private func checkLocationAuthorization(){
        guard let locationManager = locationManager else { return
        }
        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Your location restricted likely due to parental controls.")
        case .denied:
            print("You have denied this app location permission. Go into settings to change it.")
        case .authorizedAlways, .authorizedWhenInUse:
            region = MKCoordinateRegion(center: locationManager.location!.coordinate , span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        @unknown default:
            break
        }
        
    }
    
    /*In case user can change location permissions*/
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}


//class LocationViewModel: NSObject, ObservableObject {
//    private var locationManager: CLLocationManager?
//    @Published var speed: Double = 0.0
//    @Published var log: String = ""
//
//    init(locationManager: CLLocationManager = CLLocationManager()) {
//        super.init()
//        self.locationManager = locationManager
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//    }
//    func startMonitoringEarthquakes() {
//            locationManager?.requestWhenInUseAuthorization()
//            if CLLocationManager.locationServicesEnabled() {
//                locationManager?.startUpdatingLocation()
//            }
//        }
//
//        private func sendNotification() {
//            let content = UNMutableNotificationContent()
//            content.title = "Earthquake Alert!"
//            content.body = "An earthquake has occurred nearby."
//            content.sound = UNNotificationSound.default
//
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//
//            UNUserNotificationCenter.current().add(request)
//        }
//}
//
//extension LocationViewModel: CLLocationManagerDelegate {
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        switch manager.authorizationStatus {
//        case .notDetermined:
//            log = "Location authorization not determined"
//        case .restricted:
//            log = "Location authorization restricted"
//        case .denied:
//            log = "Location authorization denied"
//        case .authorizedAlways:
//            manager.requestLocation()
//            log = "Location authorization always granted"
//        case .authorizedWhenInUse: manager.startUpdatingLocation()
//            log = "Location authorization when in use granted"
//        @unknown default:
//            log = "Unknown authorization status"
//        }
//
//    }
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
////        locations.forEach { location in
////            self.speed = location.speed
////        }
//
//        guard let location = locations.last else { return }
//                speed = location.speed
//
//                // Check if earthquake happened nearby (within 10 km)
//                let almatyLocation = CLLocation(latitude: 29.7604, longitude: -95.3698) // Almaty, Kazakhstan coordinates
//                let distance = location.distance(from: almatyLocation) // Distance in meters
//
//                if distance < 100000 { // Monitor earthquakes within 10 km of Almaty
//                    // Send notification
//                    sendNotification()
//                }
//
//        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//                switch manager.authorizationStatus {
//                case .authorizedAlways, .authorizedWhenInUse:
//                    manager.startUpdatingLocation()
//                default:
//                    break
//                }
//            }
//    }
//
//}


#Preview {
    EarthquakesMapView()
}
