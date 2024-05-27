//
//  MainView.swift
//  My EartquakeAlert
//
//  Created by Амангелди Мадина on 08.05.2024.
//

import Foundation
import SwiftUI

struct RecentEarthquakesView: View {
    @StateObject var viewModel = ViewModel()
    
    @State private var selectedPlace: String?

    
    var body: some View {
//
        NavigationView {

            
            List(viewModel.earthquakes.suffix(25), id: \.id) { earthquake in
                    VStack(alignment: .leading, spacing: 5) {
//
                        
                        HStack {
//                                                Text("Location:")
//                                                    .fontWeight(.bold)
                            Text("\(earthquake.properties.place)")
                        }
                                            
                        HStack {
//
                            Text("\(viewModel.formattedDate(from: earthquake.properties.time))")
                        }
                        HStack {
                            
                            Text(String(format: "%.1f", earthquake.properties.mag))
                                            .foregroundColor(color(forMagnitude: earthquake.properties.mag))
                                            .font(.system(size: 24, weight: .bold))

                        }
                    }
                    .padding(8)
                }
                .navigationTitle("Recent Earthquakes")
                .onAppear {
                    viewModel.fetch()
                }
            
        }
        
    }
    
    func color(forMagnitude magnitude: Double) -> Color {
        switch magnitude {
        case ..<2:
            return .green
        case 2..<4:
            return .yellow
        default:
            return .red
        }
    }
    
//    func filteredEarthquakes() -> [Earthquake] {
//            guard let selectedPlace = selectedPlace else {
//                return viewModel.earthquakes.suffix(25)
//            }
//            return viewModel.earthquakes.filter { $0.properties.place.contains(selectedPlace) }.suffix(25)
//        }
}

#Preview {
    RecentEarthquakesView()
}
