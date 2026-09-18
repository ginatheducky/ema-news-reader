//
//  ema_news_reader_appTests.swift
//  ema-news-reader-appTests
//
//  Created by christina on 17.09.26.
//

import Testing
import Foundation

@testable import ema_news_reader_app

struct ema_news_reader_appTests {

    @Test func decodesNewsAndCleansCategories() throws {
        let json = """
    {
        "meta": { "total_records": 1 },
        "data": [
            {
                "title": "Test article",
                "news_summary": "",
                "categories": "Human; Veterinary; ;",
                "topics": "Medicines; Innovation"
            }
        ]
    }
    """
        
        let bytes = Data(json.utf8)
        let feed = try JSONDecoder().decode(NewsFeed.self, from: bytes)
        
        #expect(feed.data.count == 1)
        
        let article = try #require(feed.data.first)
        
        #expect(article.title == "Test article")
        #expect(article.newsSummary == "")
        #expect(article.categoryValues == ["Human", "Veterinary"])
    }

}
