//
//  ema_news_readerApp.swift
//  ema-news-reader
//
//  Created by christina on 16.10.26.
//

import SwiftUI

@main
struct ema_news_readerApp: App {
    
    @State private var newsStore: NewsStore
    @State private var eventsStore: EventsStore
    @State private var guidelinesStore: GuidelinesStore
    
    init() {
        let client = EMAClient()
        
        _newsStore = State(initialValue: NewsStore(
            loader: NewsFeedLoader(client: client)
        ))
        _eventsStore = State(initialValue: EventsStore(
            loader: EventsFeedLoader(client: client)
        ))
        _guidelinesStore = State(initialValue: GuidelinesStore(
            loader: GuidelinesFeedLoader(client: client)
        ))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(newsStore)
                .environment(eventsStore)
                .environment(guidelinesStore)
        }
    }
}
