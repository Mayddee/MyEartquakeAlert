//
//  ContentView.swift
//  My EartquakeAlert
//
//  Created by Амангелди Мадина on 08.05.2024.
//

import SwiftUI
import CoreLocation
import MapKit


//struct Earthquake: Hashable, Codable {
////    let id: UUID
//    let place: String
//    let mag: Double
//    let time: TimeInterval
//    
//}
struct EarthquakeData: Codable {
    let features: [Earthquake]
}

struct Earthquake: Codable {
    let properties: Properties
    let geometry: Geometry
    let id: String
}

struct Properties: Codable {
    let mag: Double
    let place: String
    let time: TimeInterval
    let updated: TimeInterval
    let url: URL
    let detail: URL
    let status: String
    let tsunami: Int
    let sig: Int
    let magType: String
    let title: String
}

struct Geometry: Codable {
    let type: String
    let coordinates: [Double]?
}





class ViewModel: ObservableObject {
    @Published var earthquakes: [Earthquake] = []
    @Published var nearbyEarthquakes: [Earthquake] = []


    
    func formattedDate(from time: TimeInterval) -> String {
        // Convert milliseconds to seconds
        let seconds = time / 1000.0
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        let date = Date(timeIntervalSince1970: seconds)
        return dateFormatter.string(from: date)
    }
    
    @Published var uniquePlaces: [String] = []
    @Published var selectedPlace: String?



    
    
    func fetch(){
        guard let url = URL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson") else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self]
            data, _,
            error in
            guard let data = data, error == nil else {
                print("No earthquake data")
                return
            }
            //Convert to JSON
            do {
//
                let decoder = JSONDecoder()
                let earthquakeData = try decoder.decode(EarthquakeData.self, from: data)
                DispatchQueue.main.async {
                    
                                    
                self?.earthquakes = earthquakeData.features
                }
            }
            catch {
                print(error)
            }
        }
        
        task.resume()
        updateUniquePlaces()

    }
    
    private func updateUniquePlaces() {
            var uniquePlacesSet = Set<String>()
            for earthquake in earthquakes {
                uniquePlacesSet.insert(earthquake.properties.place)
            }
            uniquePlaces = Array(uniquePlacesSet)
        }
    
    func filteredEarthquakes() -> [Earthquake] {
            if let selectedPlace = selectedPlace {
                return earthquakes.filter { $0.properties.place == selectedPlace }
            } else {
                return earthquakes
            }
        }
}



struct ContentView: View {

    @StateObject var viewModel = ViewModel()
    let facebookURL = URL(string: "https://www.facebook.com/your_page")!

    
    var body: some View {
        TabView {
            RecentEarthquakesView()
            .tabItem {
                Label("Chronology", systemImage: "globe")
            }
//            NearbyEarthquakesView()
//            .tabItem {
//                Label("Nearby", systemImage: "globe")
//            }
            EarthquakesMapView()
            .tabItem {
                Label("Map", systemImage: "map")
            }
                    
            SafetyView()
            .tabItem {
                Label("Safety", systemImage: "play.rectangle")
            }
            
            FacebookView()
            .tabItem {
                Label("Social Media", systemImage: "person.2.fill")
            }
        }
        
    }
}




#Preview {
    ContentView()
}
