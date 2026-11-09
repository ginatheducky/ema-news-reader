//
//  EventsFeed.swift
//  ema-news-reader
//
//  Created by christina on 09.11.26.
//


import Foundation

struct EventsFeed: Decodable {
    let data: [EventRecord]
    let meta: MetaData
}

struct EventRecord: Codable {
    let title: String
    let dateStartEndDates: String
    let liveBroadcast: String
    let online: String
    let location: String
    let firstPublishedDate: String
    let lastUpdatedDate: String
    let eventURL: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case dateStartEndDates = "date_start_end_dates"
        case liveBroadcast = "live_broadcast"
        case online
        case location
        case firstPublishedDate = "first_published_date"
        case lastUpdatedDate = "last_updated_date"
        case eventURL = "event_url"
    }
}
