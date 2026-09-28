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
            articles = try await loadArticles()
        } catch is CancellationError {
            // Cancellation is not a failed download to report.
        } catch {
            errorMessage = "News couldn’t be loaded. Please try again."
            print("News load failed:", error)
        }
    }
    
    
}
