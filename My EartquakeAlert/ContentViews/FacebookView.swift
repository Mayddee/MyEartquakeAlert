//
//  FacebookView.swift
//  My EartquakeAlert
//
//  Created by Амангелди Мадина on 10.05.2024.
//

import SwiftUI
import WebKit

struct WebContentView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}


struct FacebookView: View {
    let facebookURL = URL(string: "https://www.facebook.com/")!

        var body: some View {
                   NavigationView {
                       WebContentView(url: facebookURL)
                           .navigationBarTitle("Facebook")
                   }
            }
}

#Preview {
    FacebookView()
}
