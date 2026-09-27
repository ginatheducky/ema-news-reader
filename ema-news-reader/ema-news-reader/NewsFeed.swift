//
//  NewsFeed.swift
//  ema-news-reader
//
//  Created by christina on 26.09.26.
//

import Foundation

nonisolated struct NewsFeed: Decodable {
    let data: [NewsRecord]
}

nonisolated struct NewsRecord: Decodable {
    let title: String
    let newsSummary: String
    let categories: String
    let topics: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case newsSummary = "news_summary"
        case categories
        case topics
    }
    
    var categoryValues: [String] {
        categories
            .split(separator: ";")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    var topicValues: [String] {
        topics
            .split(separator: ";")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    var displaySummary: String? {
        let trimmed = newsSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return nil
        }
        
        return trimmed
    }
    
}
