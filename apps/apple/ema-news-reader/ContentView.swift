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
    @Environment(NewsStore.self) private var newsStore
    
    @State private var selectedTab: AppTab = .briefing
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("News", systemImage: "newspaper", value: AppTab.news) {
                if let feedURL = EMAFeedURLs.news {
                    NewsScreen(feedURL: feedURL, store: newsStore)
                } else {
                    Text("The News feed URL is unavailable.")
                }
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
    let fixture = Result(catching: { try NewsItem.loadPreviewData() })
    let client = EMAClient(request: { url in
        guard let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        ) else {
            throw URLError(.badServerResponse)
        }
        
        return (try fixture.get(), response)
    })
    
    let store = NewsStore(loader: NewsFeedLoader(client: client))

    ContentView()
        .environment(store)
        .task {
            if let url = EMAFeedURLs.news {
                await store.refreshIfNeeded(from: url)
            }
        }
}
