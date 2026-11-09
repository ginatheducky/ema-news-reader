//
//  NewsStore.swift
//  ema-news-reader
//
//  Created by christina on 09.11.26.
//

import Foundation
import Observation

@MainActor
@Observable
final class NewsStore {
    private(set) var feed: LoadedNewsFeed?
    private(set) var lastSuccessfulCheck: Date?
    private(set) var isLoading = false
    private(set) var lastError: (any Error)?
    
    private let loader: NewsFeedLoader
    private let now: () -> Date
    
    init(loader: NewsFeedLoader, now: @escaping () -> Date = { Date() }) {
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
