//
//  EventsFeedLoader.swift
//  ema-news-reader
//
//  Created by christina on 09.11.26.
//

import Foundation

enum EventsFeedLoaderError: Error, Equatable {
    case noUsableRecords
}

struct LoadedEventsFeed {
    let items: [EventItem]
    let meta: MetaData
}

struct EventsFeedLoader {
    let client: EMAClient
    
    func load(from url: URL) async throws -> LoadedEventsFeed {
        let bytes = try await client.fetchData(from: url)
        let feed = try JSONDecoder().decode(EventsFeed.self, from: bytes)
        
        let items = feed.data.compactMap { record in
            EventItemMapper.map(record)
        }
        
        if !feed.data.isEmpty && items.isEmpty {
            throw EventsFeedLoaderError.noUsableRecords
        }
        
        return LoadedEventsFeed(items: items, meta: feed.meta)
    }
}
