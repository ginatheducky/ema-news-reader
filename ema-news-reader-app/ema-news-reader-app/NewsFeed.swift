//
//  NewsFeed.swift
//  ema-news-reader-app
//
//  Created by christina on 18.09.26.
//

// JSON data from EMA
// {
//      "meta" : { ... },
//      "data" : [ { event item }, { event item }]
// }

//{
//    "title": "Meeting highlights from the Committee for Veterinary Medicinal Products (CVMP) 14-16 April 2026",
//    "press_release": "No",
//    "related_medicine_referral": "Nobivac NXT HCPChFeLV;Solensia;Startvac;Vectormune HVT-AIV",
//    "categories": "Veterinary",
//    "topics": "Medicines",
//    "news_summary": "Outcomes of the Committee for Veterinary Medicinal Products (CVMP) meeting",
//    "first_published_date": "17/04/2026",
//    "last_updated_date": "",
//    "news_url": "https://www.ema.europa.eu/en/news/meeting-highlights-committee-veterinary-medicinal-products-cvmp-14-16-april-2026"
//},

import Foundation

nonisolated struct NewsFeed: Decodable {
    let data: [NewsRecord]
    
    var newestFirst: [NewsRecord] {
        let datedRecords = data.map { article in
            (article: article, date: article.publicationDate ?? Date.distantPast)
        }
        
        return datedRecords
            .sorted { first, second in first.date > second.date }
            .map { entry in entry.article }
    }
}

nonisolated struct NewsRecord: Decodable {
    let title: String
    let newsSummary: String
    let categories: String
    let topics: String
    let newsURL: String
    let firstPublishedDate: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case newsSummary = "news_summary"
        case categories = "categories"
        case topics = "topics"
        case newsURL = "news_url"
        case firstPublishedDate = "first_published_date"
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
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.isLenient = false
        
        guard let date = formatter.date(from: firstPublishedDate),
              formatter.string(from: date) == firstPublishedDate else {
            return nil
        }
        
        return date
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
            firstPublishedDate: "31/08/2026"
        ),
        NewsRecord(
            title: "Sample: September news",
            newsSummary: "",
            categories: "Human;Veterinary",
            topics: "Innovation",
            newsURL: "https://example.com/news/september",
            firstPublishedDate: "01/09/2026"
        ),
        NewsRecord(
            title: "Sample: Another year, July",
            newsSummary: "",
            categories: "Human;Veterinary",
            topics: "Innovation",
            newsURL: "https://example.com/news/July2025",
            firstPublishedDate: "04/07/2025"
        ),
        NewsRecord(
            title: "Sample: Date unavailable",
            newsSummary: "",
            categories: "Human;Veterinary",
            topics: "Innovation",
            newsURL: "https://example.com/news/unavailable",
            firstPublishedDate: ""
        )
    ]
}
