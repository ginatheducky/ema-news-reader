//
//  NewsFeedSnapshot.swift
//  ema-news-reader
//
//  Created by christina on 15.11.26.
//

import Foundation

struct NewsFeedSnapshot: Codable {
    var schemaVersion: Int = 1
    var items: [NewsItem]
    let exportTimestamp: String // EMA export timestamp from LoadedNewsFeed.meta
    var lastSuccessfulCheck: Date // the date when the app successfully checked the feed
}

