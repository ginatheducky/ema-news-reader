//
//  NewsItemMapper.swift
//  ema-news-reader
//
//  Created by christina on 09.11.26.
//

import Foundation

enum NewsItemMapper {
    static func map(_ record: NewsRecord) -> NewsItem? {
        guard let url = URL(string: record.newsURL),
              url.scheme?.lowercased() == "https",
              let host = url.host,
              !host.isEmpty else {
            return nil
        }
        
        // press release
        let pressRelease: Bool
        switch record.pressRelease {
        case "Yes": pressRelease = true
        case "No": pressRelease = false
        default: return nil
        }
        
        // date formatter
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "dd/MM/yyyy"
        
        guard let publishedDate = parseDate(record.firstPublishedDate, using: formatter) else {
            return nil
        }
        
        
        func splitList(_ value: String) -> [String] {
            value.split(separator: ";")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }
        
        func parseDate(_ value: String, using formatter: DateFormatter) -> Date? {
            guard let date = formatter.date(from: value),
                  formatter.string(from: date) == value else {
                return nil
            }
            return date
        }
        
        return NewsItem(
            title: record.title,
            pressRelease: pressRelease,
            relatedMedicineReferral: splitList(record.relatedMedicineReferral),
            categories: splitList(record.categories),
            topics: splitList(record.topics),
            newsSummary: record.newsSummary,
            firstPublishedDate: publishedDate,
            lastUpdatedDate: parseDate(record.lastUpdatedDate, using: formatter),
            newsURL: url
        )
    }
}
