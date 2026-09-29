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
    private(set) var updatedArticleURLs: Set<String> = []
    private(set) var cacheErrorMessage: String?
    
    private let loadArticles: () async throws -> [NewsRecord]
    private let now: () -> Date
    private let preferences: UserDefaults?
    private static let readArticleURLsKey = "news.readArticleURLs"
    private let cache: NewsCache?
    private var hasAttemptedCacheRestore = false
    private var pendingSave: Task<Void, Never>?
    
    
    init(
        preferences: UserDefaults? = .standard,
        cache: NewsCache? = nil,
        now: @escaping () -> Date = { Date() },
        loadArticles: @escaping () async throws -> [NewsRecord] = {
            try await NewsService().fetchArticles()
        }
    ) {
        self.preferences = preferences
        self.cache = cache
        self.now = now
        self.loadArticles = loadArticles
        
        self.readArticleURLs = Set(
            preferences?.stringArray(
                forKey: Self.readArticleURLsKey
            ) ?? []
        )
    }
    
    
    func markAsRead(_ article: NewsRecord) {
        let removedNew = newArticleURLs.remove(article.newsURL) != nil
        
        var removedUpdated = false
        
        if let currentArticle = articles?.first(where: {
            $0.newsURL == article.newsURL
        }), currentArticle == article {
            removedUpdated = updatedArticleURLs.remove(article.newsURL) != nil
        }
        
        let result = readArticleURLs.insert(article.newsURL)
        
        if result.inserted {
            preferences?.set(
                readArticleURLs.sorted(),
                forKey: Self.readArticleURLsKey
            )
        }
        
        if removedNew || removedUpdated || result.inserted {
            queueSnapshotSave()
        }
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
    
    
    private func updateChangedArticles(
        using downloadedArticles: [NewsRecord]
    ) {
        guard let previousArticles = articles else {
            updatedArticleURLs = []
            return
        }
        
        let downloadedURLs = Set(downloadedArticles.map(\.newsURL))
        
        updatedArticleURLs.formIntersection(downloadedURLs)
        
        let previousByURL = Dictionary(
            uniqueKeysWithValues: previousArticles.map {
                ($0.newsURL, $0)
            }
        )
        
        for article in downloadedArticles {
            guard let previous = previousByURL[article.newsURL] else {
                continue
            }
            
            if article.hasUpdate(comparedTo: previous) {
                updatedArticleURLs.insert(article.newsURL)
            }
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
            await restoreCacheIfNeeded()
            try Task.checkCancellation()
            
            let downloadedArticles = try await loadArticles()
            try Task.checkCancellation()
            
            updateNewArticles(using: downloadedArticles)
            updateChangedArticles(using: downloadedArticles)
            
            articles = downloadedArticles
            lastSuccessfulRefresh = now()
            
            queueSnapshotSave()
            await waitForPendingSave()
        } catch is CancellationError {
            // The task was cancelled; keep the current articles.
        } catch let error as URLError where error.code == .cancelled {
            // The network request was cancelled.
        } catch {
            errorMessage = "News couldn't be loaded. Please try again."
            print("News load failed:", error)
        }
    }
    
    
    private func restoreCacheIfNeeded() async {
        guard !hasAttemptedCacheRestore else {
            return
        }
        
        hasAttemptedCacheRestore = true
        
        guard let cache else {
            return
        }
        
        do {
            guard let snapshot = try await cache.load() else {
                return
            }
            
            var seenURLs: Set<String> = []
            let restoredArticles = snapshot.articles.filter {
                seenURLs.insert($0.newsURL).inserted
            }
            
            let restoredURLs = Set(restoredArticles.map(\.newsURL))
            
            articles = restoredArticles
            lastSuccessfulRefresh = snapshot.lastSuccessfulRefresh
            
            newArticleURLs = snapshot.newArticleURLs
                .intersection(restoredURLs)
                .subtracting(readArticleURLs)
            
            updatedArticleURLs = snapshot.updatedArticleURLs
                .intersection(restoredURLs)
        } catch {
            print("News cache restore failed:", error)
        }
    }
    
    
    private func queueSnapshotSave() {
        guard let cache,
              let articles,
              let lastSuccessfulRefresh else {
            return
        }
        
        let snapshot = NewsSnapshot(
            articles: articles,
            newArticleURLs: newArticleURLs,
            updatedArticleURLs: updatedArticleURLs,
            lastSuccessfulRefresh: lastSuccessfulRefresh
        )
        
        let previousSave = pendingSave
        
        pendingSave = Task {
            await previousSave?.value
            
            do {
                try await cache.save(snapshot)
                cacheErrorMessage = nil
            } catch {
                cacheErrorMessage =
                "News is available, but the latest changes couldn't be saved for offline use."
                print("News cache save failed:", error)
            }
        }
    }
    
    
    func waitForPendingSave() async {
        await pendingSave?.value
    }
}
