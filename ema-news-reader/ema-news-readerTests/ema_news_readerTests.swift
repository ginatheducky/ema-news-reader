//
//  ema_news_readerTests.swift
//  ema-news-readerTests
//
//  Created by christina on 26.09.26.
//

import Testing
import Foundation
@testable import ema_news_reader

struct ema_news_readerTests {

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
        #expect(article.topicValues == ["Medicines", "Innovation"])
        #expect(article.displaySummary == nil)
    }
    
    @Test(arguments: ["", " ", ";", " ; ; "])
    func emptyCategoryAndTopicValuesProduceEmptyArrays(raw: String) {
        let article = NewsRecord(
            title: "Test article",
            newsSummary: "",
            categories: raw,
            topics: raw
        )
        
        #expect(article.categoryValues.isEmpty)
        #expect(article.topicValues.isEmpty)
    }
    
    @Test func rejectsNumericCategories() {
        let json = """
    {
        "title": "Test article",
        "news_summary": "",
        "categories": 42,
        "topics": "Medicines"
    }
    """
        
        #expect(throws: DecodingError.self) {
            _ = try JSONDecoder().decode(
                NewsRecord.self,
                from: Data(json.utf8)
            )
        }
    }

}
