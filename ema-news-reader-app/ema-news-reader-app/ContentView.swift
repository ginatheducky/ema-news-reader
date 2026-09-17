//
//  ContentView.swift
//  ema-news-reader-app
//
//  Created by christina on 17.09.26.
//

import SwiftUI

enum AppTab: Hashable {
    case news
    case events
    case briefing
    case guidance
    case media
}


struct ContentView: View {
    // @State give SwiftUI ownership of this changing value; it's temporary UI state, so a fresh app launch starts with .briefing again
    @State private var selectedTab: AppTab = .briefing
    
    // @AppStorage connects a property to UserDefaults, Apple's storage for small preferences; brifing.showNews is the persistent storage key; true is the fallback when no preference has been saved
    @AppStorage("briefing.showNews") private var showNews = true
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("News", systemImage: "newspaper", value: AppTab.news) {
                NavigationStack {
                    Text("News will appear here.")
                        .navigationTitle("News")
                }
            }
            
            Tab("Events", systemImage: "calendar", value: AppTab.events) {
                NavigationStack {
                    Text("Events will appear here.")
                        .navigationTitle("Events")
                }
            }
            
            Tab("Your Briefing", systemImage: "house", value: AppTab.briefing) {
                briefingContent
            }
            
            Tab("Guidance", systemImage: "book", value: AppTab.guidance) {
                NavigationStack {
                    Text("Guidance will appear here.")
                        .navigationTitle("Guidance")
                }
            }
            
            Tab("Media", systemImage: "play.circle", value: AppTab.media) {
                NavigationStack {
                    Text("YouTube videos will be added in a later update.")
                        .navigationTitle("Media")
                }
            }
        }
    }

    private var briefingContent: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your EMA overview")
                        .font(.headline)
                    
                    Text("News, events and guidance will appear here.")
                        .foregroundStyle(.secondary)
                    
                    Toggle("Show News in your briefing", isOn: $showNews)
                    
                    if showNews {
                        NewsCard(category: "Human", title: "Sample news title for layout testing.", summary: nil, isNew: true)
                        
                        NewsCard(category: "Human", title: "Sample news title for layout testing.", summary: "Sample summary used to check spacing and readability.", isNew: true)
                        
                        NewsCard(category: "Human", title: "Sample news title for layout testing. Sample news title for layout testing. Sample news title for layout testing.", summary: "Sample summary used to check spacing and readability.", isNew: true)
                        
                        NewsCard(category: "Human", title: "Sample news title for layout testing.", summary: "Sample summary used to check spacing and readability.", isNew: false)
                        
                        NewsCard(category: "Human", title: "Sample news title for layout testing.", summary: "Sample summary used to check spacing and readability.", isNew: false)
                        
                        NewsCard(category: "Human", title: "Sample news title for layout testing.", summary: "Sample summary used to check spacing and readability.", isNew: false)
                    } else {
                        Text("News Items are hidden and can be enabled above.")
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .background(Color.blue.opacity(0.08))
            .navigationTitle("Your Briefing")
        }
    }
}



#Preview {
    ContentView()
}
