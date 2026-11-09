//
//  GuidelineItemMapperTests.swift
//  ema-news-reader
//
//  Created by christina on 09.11.26.
//

import Testing
import Foundation

@testable import ema_news_reader

struct GuidelineItemMapperTests {
    @MainActor
    @Test func mapsCategoryAndDate() throws {
        let json = """
        {
          "meta": {
            "total_records": 1,
            "timestamp": "2026-11-08T18:00:20Z"
          },
          "data": [
            {
                "title": "Investigation of bioequivalence",
                "category": "Human;Herbal; ",
                "first_published_date": "29/01/2010",
                "last_updated_date": "",
                "url": "https://www.ema.europa.eu/en/scientific-guidelines/investigation-bioequivalence"
            }
          ]
        }
        """
        
        let feed = try JSONDecoder().decode(GuidelinesFeed.self, from: Data(json.utf8))
        let record = try #require(feed.data.first)

        let item = try #require(GuidelineItemMapper.map(record))
        
        #expect(item.category == ["Human", "Herbal"])
        #expect(item.lastUpdatedDate == nil)
        
    }
}
