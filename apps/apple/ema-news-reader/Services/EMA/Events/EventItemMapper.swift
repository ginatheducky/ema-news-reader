//
//  EventItemMapper.swift
//  ema-news-reader
//
//  Created by christina on 09.11.26.
//

import Foundation

enum EventItemMapper {
    static func map(_ record: EventRecord) -> EventItem? {
        guard let url = URL(string: record.eventURL),
              url.scheme?.lowercased() == "https",
              let host = url.host,
              !host.isEmpty else {
            return nil
        }
        
        // live broadcast
        let liveBroadcast: Bool
        switch record.liveBroadcast {
        case "Yes": liveBroadcast = true
        case "No": liveBroadcast = false
        default: return nil
        }
        
        // is online
        let online: Bool
        switch record.online {
        case "Yes": online = true
        case "No": online = false
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
        
        let scheduleText = record.dateStartEndDates
        
        func parseDate(_ value: String, using formatter: DateFormatter) -> Date? {
            guard let date = formatter.date(from: value),
                  formatter.string(from: date) == value else {
                return nil
            }
            return date
        }
        
        return EventItem(
            title: record.title,
            dateStartEndDates: scheduleText,
            liveBroadcast: liveBroadcast,
            online: online,
            location: record.location.isEmpty ? nil : record.location,
            firstPublishedDate: publishedDate,
            lastUpdatedDate: parseDate(record.lastUpdatedDate, using: formatter),
            eventURL: url
        )
    }
}
