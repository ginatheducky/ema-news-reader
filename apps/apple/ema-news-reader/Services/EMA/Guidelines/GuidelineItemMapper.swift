//
//  GuidelineItemMapper.swift
//  ema-news-reader
//
//  Created by christina on 09.11.26.
//

import Foundation

enum GuidelineItemMapper {
    static func map(_ record: GuidelineRecord) -> GuidelineItem? {
        guard let url = EMARecordParsing.httpsURL(from: record.guidelineURL) else {
            return nil
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
        
        return GuidelineItem(
            title: record.title,
            category: splitList(record.category),
            firstPublishedDate: publishedDate,
            lastUpdatedDate: parseDate(record.lastUpdatedDate, using: formatter),
            guidelineURL: url
        )
    }
}
