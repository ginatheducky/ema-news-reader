//
//  NewsFeedLoader.swift
//  ema-news-reader
//
//  Created by christina on 09.11.26.
//

import Foundation

enum NewsFeedLoaderError: Error, Equatable {
    case noUsableRecords
}

struct LoadedNewsFeed {
    let items: [NewsItem]
    let meta: MetaData
}

struct NewsFeedLoader {
    let client: EMAClient
    
    func load(from url: URL) async throws -> LoadedNewsFeed {
        let bytes = try await client.fetchData(from: url)
        let feed = try JSONDecoder().decode(NewsFeed.self, from: bytes)
        
        let items = feed.data.compactMap { record in
            NewsItemMapper.map(record)
        }
        
        if !feed.data.isEmpty && items.isEmpty {
            throw NewsFeedLoaderError.noUsableRecords
        }
        
        return LoadedNewsFeed(items: items, meta: feed.meta)
    }
}
