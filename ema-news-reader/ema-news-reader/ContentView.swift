//
//  ContentView.swift
//  ema-news-reader
//
//  Created by christina on 26.09.26.
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
    @State private var selectedTab: AppTab = .briefing
    
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
            
            Tab("Your Briefing", systemImage: "newspaper", value: AppTab.briefing) {
                briefingContent
            }
            
            Tab("Guidance", systemImage: "book", value: AppTab.guidance) {
                NavigationStack {
                    Text("Guidance will appear here.")
                        .navigationTitle("News")
                }
            }
            
            Tab("Media", systemImage: "play.circle", value: AppTab.media) {
                NavigationStack {
                    Text("Media will appear here.")
                        .navigationTitle("Media")
                }
            }
        }
    }
    
    private var briefingContent: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Your EMA overview")
                    .font(.headline)
                
                Text("News, events and guidance will appear here.")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
            .navigationTitle("Your Briefing")
        }
    }

    
}

#Preview {
    ContentView()
}
