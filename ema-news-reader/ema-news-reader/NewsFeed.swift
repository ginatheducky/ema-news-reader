//
//  NewsFeed.swift
//  ema-news-reader
//
//  Created by christina on 26.09.26.
//

import Foundation

nonisolated enum CategoryMatchMode: String {
    case any
    case all
}

nonisolated enum TopicMatchMode: String {
    case any
    case all
}

nonisolated struct NewsFeed: Decodable, Sendable {
    let data: [NewsRecord]
    
    // sort dates: an unparseable date uses Date.distantPast; for equal dates: Swift’s stable sort preserves their incoming order
    var newestFirst: [NewsRecord] {
        let datedRecords = data.map { article in
            (
                article: article,
                date: article.publicationDate ?? Date.distantPast
            )
        }
        
        return datedRecords
            .sorted { first, second in
                first.date > second.date
            }
            .map { entry in
                entry.article
            }
    }
    
    var availableCategories: [String] {
        // [["Human"], ["Human", "Veterinary"]] -> ["Human", "Human", "Veterinary"] -> ["Human", "Veterinary"]
        let values = data.flatMap { article in
            article.categoryValues
        }
        
        return Set(values).sorted()
    }
    
    var availableTopics: [String] {
        let values = data.flatMap { article in
            article.topicValues
        }
        
        return Set(values).sorted()
    }
}

nonisolated struct NewsRecord: Decodable, Sendable, Hashable {
    let title: String
    let newsSummary: String
    let categories: String
    let topics: String
    let newsURL: String
    let firstPublishedDate: String
    let lastUpdatedDate: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case newsSummary = "news_summary"
        case categories
        case topics
        case newsURL = "news_url"
        case firstPublishedDate = "first_published_date"
        case lastUpdatedDate = "last_updated_date"
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
    
    var articleURL: URL? {
        guard let url = URL(string: newsURL),
              let scheme = url.scheme?.lowercased(),
              scheme == "https" || scheme == "http",
              let host = url.host,
              !host.isEmpty else {
            return nil
        }
        
        return url
    }
    
    var publicationDate: Date? {
        Self.parseEMADate(firstPublishedDate)
    }
    
    var updatedDate: Date? {
        Self.parseEMADate(lastUpdatedDate)
    }
    
    private static func parseEMADate(_ value: String?) -> Date? {
        guard let value else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.isLenient = false
        
        guard let date = formatter.date(from: value),
              formatter.string(from: date) == value else {
            return nil
        }
        
        return date
    }
    
    func hasUpdate(comparedTo previous: NewsRecord) -> Bool {
        guard newsURL == previous.newsURL else {
            return false
        }
        
        let contentChanged =
        title != previous.title ||
        newsSummary != previous.newsSummary ||
        categories != previous.categories ||
        topics != previous.topics ||
        firstPublishedDate != previous.firstPublishedDate
        
        if contentChanged {
            return true
        }
        
        guard let currentDate = updatedDate else {
            return false
        }
        
        guard let previousDate = previous.updatedDate else {
            return true
        }
        
        return currentDate > previousDate
    }
    
    func matchesSearch(_ query: String) -> Bool {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return true
        }
        
        return title.localizedStandardContains(trimmed)
        || newsSummary.localizedStandardContains(trimmed)
    }
    
    func matchesCategories(_ selected: Set<String>, mode: CategoryMatchMode = .any) -> Bool {
        if selected.isEmpty {
            return true
        }
        
        switch mode {
        case .any:
            return categoryValues.contains { category in
                selected.contains(category)
            }
            
        case .all:
            return selected.isSubset(of: Set(categoryValues))
        }
    }
    
    func matchesTopics(_ selected: Set<String>, mode: TopicMatchMode = .any) -> Bool {
        if selected.isEmpty {
            return true
        }
        
        switch mode {
        case .any:
            return topicValues.contains { topic in
                selected.contains(topic)
            }
            
        case .all:
            return selected.isSubset(of: Set(topicValues))
        }
    }
    
    func matchesFilters(
        query: String,
        categories: Set<String>,
        categoryMode: CategoryMatchMode,
        topics: Set<String>,
        topicMode: TopicMatchMode
    ) -> Bool {
        matchesSearch(query)
        && matchesCategories(categories, mode: categoryMode)
        && matchesTopics(topics, mode: topicMode)
    }
}


extension NewsRecord {
    static let samples: [NewsRecord] = [
        NewsRecord(
            title: "Sample: August news",
            newsSummary: "Example content for testing the news screen.",
            categories: "Human",
            topics: "Medicines",
            newsURL: "https://example.com/news/august",
            firstPublishedDate: "31/08/2026",
            lastUpdatedDate: "01/09/2026"
        ),
        NewsRecord(
            title: "Sample: September news",
            newsSummary: "Outcomes of the Committee for Veterinary Medicinal Products (CVMP) meeting",
            categories: "Human;Veterinary",
            topics: "Innovation;Test",
            newsURL: "https://example.com/news/september",
            firstPublishedDate: "01/09/2026",
            lastUpdatedDate: ""
        ),
        NewsRecord(
            title: "Sample: Another year, July",
            newsSummary: "",
            categories: "Veterinary",
            topics: "Innovation",
            newsURL: "https://example.com/news/July2025",
            firstPublishedDate: "04/07/2025",
            lastUpdatedDate: ""
        ),
        NewsRecord(
            title: "Sample: Date unavailable",
            newsSummary: "",
            categories: "Corporate",
            topics: "Innovation",
            newsURL: "https://example.com/news/unavailable",
            firstPublishedDate: "",
            lastUpdatedDate: ""
        ),
        NewsRecord(
            title: "Sample: August2 news",
            newsSummary: "Example content for testing the news screen.",
            categories: "Human;Corporate",
            topics: "Medicines",
            newsURL: "https://example.com/news/august2",
            firstPublishedDate: "15/08/2026",
            lastUpdatedDate: ""
        )
    ]
}
