//
//  GuidelinesFeedLoader.swift
//  ema-news-reader
//
//  Created by christina on 09.11.26.
//

import Foundation

enum GuidelinesFeedLoaderError: Error, Equatable {
    case noUsableRecords
}

struct LoadedGuidelinesFeed {
    let items: [GuidelineItem]
    let meta: MetaData
}

struct GuidelinesFeedLoader {
    let client: EMAClient
    
    func load(from url: URL) async throws -> LoadedGuidelinesFeed {
        let bytes = try await client.fetchData(from: url)
        let feed = try JSONDecoder().decode(GuidelinesFeed.self, from: bytes)
        
        let items = feed.data.compactMap { record in
            GuidelineItemMapper.map(record)
        }
        
        if !feed.data.isEmpty && items.isEmpty {
            throw GuidelinesFeedLoaderError.noUsableRecords
        }
        
        return LoadedGuidelinesFeed(items: items, meta: feed.meta)
    }
}
