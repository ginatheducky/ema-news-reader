//
//  NewsSnapshot.swift
//  ema-news-reader
//
//  Created by christina on 29.09.26.
//

import Foundation

// timestamp is nonoptional here because snapshots are created only after a successful load
nonisolated struct NewsSnapshot: Codable, Sendable, Equatable {
    let articles: [NewsRecord]
    let newArticleURLs: Set<String>
    let updatedArticleURLs: Set<String>
    let lastSuccessfulRefresh: Date
}
