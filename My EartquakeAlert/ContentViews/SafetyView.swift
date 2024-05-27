//
//  Safety.swift
//  My EartquakeAlert
//
//  Created by Амангелди Мадина on 08.05.2024.
//

import SwiftUI
import WebKit


struct SafetyView: View {
    var body: some View {
        ScrollView {
                   VStack(spacing: 20) {
                       // Embed YouTube video
                       YouTubePlayer(videoID: "1PoEniS4Qzw")
                           .frame(height: 300)
                       
                       // Additional information
                       VStack(alignment: .leading, spacing: 10) {
                           Text("Safety Precautions During an Earthquake")
                               .font(.title)
                               .fontWeight(.bold)
                           
                           Text("1. Drop, Cover, and Hold On: Drop to your hands and knees, cover your head and neck with your arms, and hold on to any sturdy furniture until the shaking stops.")
                           
                           Text("2. Stay Indoors: Stay indoors until the shaking stops and you're sure it's safe to exit. Stay away from windows and glass.")
                           
                           Text("3. Stay Away from Doorways: Contrary to popular belief, doorways are not the safest place during an earthquake. Instead, seek cover under a sturdy piece of furniture or against an interior wall.")
                           
                           Text("4. Be Prepared: Keep emergency supplies such as water, food, flashlight, first aid kit, and sturdy shoes in an easily accessible location.")
                       }
                       .padding()
                   }
               }
    }
}

struct YouTubePlayer: UIViewRepresentable {
    let videoID: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let youtubeURL = URL(string: "https://www.youtube.com/embed/\(videoID)") else { return }
        let request = URLRequest(url: youtubeURL)
        uiView.load(request)
    }
}

#Preview {
    SafetyView()
}
