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
    
    func shouldRefresh() -> Bool {
        guard feed != nil, let checkedAt = lastSuccessfulCheck else {
            return true
        }
        
        let elapsedSeconds = now().timeIntervalSince(checkedAt)
        return elapsedSeconds > 60 * 60
    }
    
    func refreshIfNeeded(from url: URL) async {
        guard shouldRefresh() else { return }
        await refresh(from: url)
    }
    
    func refresh(from url: URL) async {
        guard !isLoading else { return } // prevent two requests from running at once
        
        isLoading = true
        lastError = nil
        
        defer { isLoading = false }
        
        do {
            let loadedFeed = try await loader.load(from: url)
            try Task.checkCancellation()
            
            feed = loadedFeed
            lastSuccessfulCheck = now()
        } catch is CancellationError {
            return
        } catch let error as URLError where error.code == .cancelled {
            return
        } catch {
            lastError = error
        }
    }
}
