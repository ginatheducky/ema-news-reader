//
//  NewsStore.swift
//  ema-news-reader
//
//  Created by christina on 28.09.26.
//

import Foundation
import Observation

@MainActor
@Observable
final class NewsStore {
    private(set) var articles: [NewsRecord]?
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    
    private let loadArticles: () async throws -> [NewsRecord]
    
    init(
        loadArticles: @escaping () async throws -> [NewsRecord] = {
            try await NewsService().fetchArticles()
        }
    ) {
        self.loadArticles = loadArticles
    }
    
    
    func loadIfNeeded() async {
        guard articles == nil else {
            return
        }
        
        await loadNews()
    }
    
    
    func loadNews() async {
        guard !isLoading else {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        do {
            let downloadedArticles = try await loadArticles()
            try Task.checkCancellation()
            articles = downloadedArticles
        } catch is CancellationError {
            // The task was cancelled; keep the current articles.
        } catch let error as URLError where error.code == .cancelled {
            // The network request was cancelled.
        } catch {
            errorMessage = "News couldn't be loaded. Please try again."
            print("News load failed:", error)
        }
    }
    
    
}
