//
//  NewsService.swift
//  ema-news-reader
//
//  Created by christina on 28.09.26.
//

import Foundation

nonisolated enum NewsServiceError: Error, Equatable {
    case invalidResponse
    case unsuccessfulStatus(Int)
}

nonisolated struct NewsService: Sendable {
    @concurrent
    func fetchArticles() async throws -> [NewsRecord] {
        let feed = try await fetchFeed()
        try Task.checkCancellation()
        
        let sorted = feed.newestFirst
        
        var seenURLs: Set<String> = []
        
        let uniqueArticles = sorted.filter { article in
            let articleURL = article.newsURL
            let insertionResult = seenURLs.insert(articleURL)
            let isFirstOccurrence = insertionResult.inserted
            
            return isFirstOccurrence
        }
        
        try Task.checkCancellation()
        return uniqueArticles
    }
    
    func fetchFeed() async throws -> NewsFeed {
        guard let url = URL(
            string: "https://www.ema.europa.eu/en/documents/report/news-json-report_en.json"
        ) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        return try Self.decodeResponse(
            data: data,
            response: response
        )
    }
    
    static func decodeResponse(data: Data, response: URLResponse) throws -> NewsFeed {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NewsServiceError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NewsServiceError.unsuccessfulStatus(
                httpResponse.statusCode
            )
        }
        
        return try JSONDecoder().decode(NewsFeed.self, from: data)
    }
}
