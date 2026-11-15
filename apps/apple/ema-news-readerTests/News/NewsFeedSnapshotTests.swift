//
//  NewsFeedSnapshotTests.swift
//  ema-news-reader
//
//  Created by christina on 15.11.26.
//

import Foundation
import Testing
@testable import ema_news_reader

struct NewsFeedSnapshotTests {
    
    @MainActor
    @Test func roundTripsNewsFeedSnapshot() throws {
        let item = NewsItem(
            title: "Older article",
            pressRelease: false,
            relatedMedicineReferral: [],
            categories: ["Human"],
            topics: ["Safety"],
            newsSummary: nil,
            firstPublishedDate: Date(timeIntervalSince1970: 0),
            lastUpdatedDate: nil,
            newsURL: try #require(URL(string: "https://example.com/news/older"))
        )
        
        let snapshot = NewsFeedSnapshot(
            items: [item],
            exportTimestamp: "2026-11-08T18:02:08Z",
            lastSuccessfulCheck: Date(timeIntervalSince1970: 0)
        )
        
        let data = try JSONEncoder().encode(snapshot)
        let restored = try JSONDecoder().decode(NewsFeedSnapshot.self, from: data)
        
        #expect(restored.schemaVersion == snapshot.schemaVersion)
        #expect(restored.exportTimestamp == snapshot.exportTimestamp)
        #expect(restored.lastSuccessfulCheck == snapshot.lastSuccessfulCheck)
        #expect(restored.items.count == 1)
        
        let restoredArticle = try #require(restored.items.first)
        
        #expect(restoredArticle.title == "Older article")
        #expect(restoredArticle.newsURL == URL(string: "https://example.com/news/older"))
        #expect(restoredArticle.newsSummary == nil)
        
    }

}
