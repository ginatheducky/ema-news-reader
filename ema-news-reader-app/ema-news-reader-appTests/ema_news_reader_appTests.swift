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
                "topics": "Medicines; Innovation",
                "news_url": "https://example.com/news/test-article"
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
        
        let url = try #require(article.articleURL)
        
        #expect(url.absoluteString == "https://example.com/news/test-article")
    }
    
    
    @Test(arguments: ["/news/test-article", ""])
    func rejectsRelativeArticleURL(raw: String) {
        let article = NewsRecord(
            title: "Test Title",
            newsSummary: "  \n",
            categories: "",
            topics:   "",
            newsURL: raw
        )
        
        #expect(article.articleURL == nil)
    }
    
    
    @Test(arguments: ["", " ", ";", " ; ; "])
    func emptyCategoryAndTopicValuesProduceEmptyArrays(raw: String) {
        let article = NewsRecord(
            title: "Test article",
            newsSummary: "",
            categories: raw,
            topics: raw,
            newsURL: "https://example.com/news/test-article"
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
        "topics": "Medicines",
        "news_url": "https://example.com/news/test-article"
    }
    """
        
        #expect(throws: DecodingError.self) {
            _ = try JSONDecoder().decode(
                NewsRecord.self,
                from: Data(json.utf8)
            )
        }
    }
    
    @Test func hidesWhitespaceOnlySummary() {
        let article = NewsRecord(
            title: "Test Title",
            newsSummary: "  \n",
            categories: "",
            topics:   "",
            newsURL: "https://example.com/news/test-article"
        )
        
        #expect(article.displaySummary == nil)
    }
    
    @Test func preservesUsefulSummary() {
        let article = NewsRecord(
            title: "Test Title",
            newsSummary: "  Example Summary. ",
            categories: "",
            topics:   "",
            newsURL: "https://example.com/news/test-article"
        )
        
        #expect(article.displaySummary == "Example Summary.")
    }

}
