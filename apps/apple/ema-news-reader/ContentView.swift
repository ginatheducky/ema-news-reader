//
//  ContentView.swift
//  ema-news-reader
//
//  Created by christina on 16.10.26.
//

import SwiftUI

enum AppTab: Hashable {
    case news
    case events
    case briefing
    case guidlines
    case media
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .briefing
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("News", systemImage: "newspaper", value: AppTab.news) {
                Text("Here the news will appear.")
            }
            
            Tab("Events", systemImage: "calendar", value: AppTab.events) {
                Text("Here the events will appear.")
            }
            
            Tab("Briefing", systemImage: "house", value: AppTab.briefing) {
                Text("Here your personal briefing.")
            }
            
            Tab("Guidelines", systemImage: "book", value: AppTab.guidlines) {
                Text("Here the scientific guidelines will appear.")
            }
            
            Tab("Media", systemImage: "play.circle", value: AppTab.media) {
                Text("Here podcasts or YouTube Videos will appear.")
            }
        }
    }
}

#Preview {
    ContentView()
}
