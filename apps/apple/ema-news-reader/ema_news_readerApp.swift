//
//  ema_news_readerApp.swift
//  ema-news-reader
//
//  Created by christina on 16.10.26.
//

import SwiftUI
import Foundation
import SwiftUI

@main
struct ema_news_readerApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    
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
                .onChange(of: scenePhase, initial: true) { _, phase in
                    guard phase == .active else { return }
                    Task {
                        await refreshFeedsIfNeeded()
                    }
                }
        }
    }
    
    private func refreshFeedsIfNeeded() async {
        guard
            let newsURL = EMAFeedURLs.news,
            let eventsURL = URL(string: "https://www.ema.europa.eu/en/documents/report/events-json-report_en.json"),
            let guidelinesURL = URL(string: "https://www.ema.europa.eu/en/documents/report/scientific-guidelines-output-json-report_en.json")
                else { return }
        
        async let news: Void = newsStore.refreshIfNeeded(from: newsURL)
        async let events: Void = eventsStore.refreshIfNeeded(from: eventsURL)
        async let guidelines: Void = guidelinesStore.refreshIfNeeded(from: guidelinesURL)
        
        _ = await (news, events, guidelines)
    }
}
