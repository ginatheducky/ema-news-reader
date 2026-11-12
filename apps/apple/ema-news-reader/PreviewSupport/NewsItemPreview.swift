//
//  NewsItemPreview.swift
//  ema-news-reader
//
//  Created by christina on 11.11.26.
//

import Foundation

extension NewsItem {
    static func loadPreviewSamples() throws -> [NewsItem] {
        let data = try loadPreviewData()
        
        let feed = try JSONDecoder().decode(NewsFeed.self, from: data)
        
        return feed.data.compactMap { record in
            NewsItemMapper.map(record)
        }
    }
    
    static func loadPreviewData() throws -> Data {
        guard let fixtureURL = Bundle.main.url(
            forResource: "NewsPreview",
            withExtension: "json"
        ) else {
            throw CocoaError(.fileNoSuchFile)
        }
        
        return try Data(contentsOf: fixtureURL)
    }
}
