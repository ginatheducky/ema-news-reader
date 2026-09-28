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
    private(set) var lastSuccessfulRefresh: Date?
    private(set) var readArticleURLs: Set<String>
    private(set) var newArticleURLs: Set<String> = []
    
    private let loadArticles: () async throws -> [NewsRecord]
    private let now: () -> Date
    private let preferences: UserDefaults?
    private static let readArticleURLsKey = "news.readArticleURLs"
    
    
    init(
        preferences: UserDefaults? = .standard,
        now: @escaping () -> Date = { Date() },
        loadArticles: @escaping () async throws -> [NewsRecord] = {
            try await NewsService().fetchArticles()
        }
    ) {
        self.preferences = preferences
        self.now = now
        self.loadArticles = loadArticles
        
        self.readArticleURLs = Set(
            preferences?.stringArray(
                forKey: Self.readArticleURLsKey
            ) ?? []
        )
    }
    
    
    func markAsRead(_ article: NewsRecord) {
        newArticleURLs.remove(article.newsURL)
        
        let result = readArticleURLs.insert(article.newsURL)
        
        guard result.inserted else {
            return
        }
        
        preferences?.set(
            readArticleURLs.sorted(),
            forKey: Self.readArticleURLsKey
        )
    }
    
    
    private func updateNewArticles(using downloadedArticles: [NewsRecord]) {
        guard let previousArticles = articles else {
            newArticleURLs = []
            return
        }
        
        let previousURLs = Set(previousArticles.map(\.newsURL))
        let downloadedURLs = Set(downloadedArticles.map(\.newsURL))
        let addedURLs = downloadedURLs.subtracting(previousURLs)
        
        if addedURLs.isEmpty {
            newArticleURLs.formIntersection(downloadedURLs)
            newArticleURLs.subtract(readArticleURLs)
        } else {
            newArticleURLs = addedURLs.subtracting(readArticleURLs)
        }
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
            
            updateNewArticles(using: downloadedArticles)
            articles = downloadedArticles
            lastSuccessfulRefresh = now()
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
