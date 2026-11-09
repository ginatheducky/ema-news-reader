//
//  EventsStore.swift
//  ema-news-reader
//
//  Created by christina on 09.11.26.
//

import Foundation
import Observation

@MainActor
@Observable
final class EventsStore {
    private(set) var feed: LoadedEventsFeed?
    private(set) var lastSuccessfulCheck: Date?
    private(set) var isLoading = false
    private(set) var lastError: (any Error)?
    
    private let loader: EventsFeedLoader
    private let now: () -> Date
    
    init(loader: EventsFeedLoader, now: @escaping () -> Date = { Date() }) {
        self.loader = loader
        self.now = now
    }
    
    func refresh(from url: URL) async {
        isLoading = true
        lastError = nil
        
        defer { isLoading = false }
        
        do {
            feed = try await loader.load(from: url)
            lastSuccessfulCheck = now()
        } catch {
            lastError = error
        }
    }
}
