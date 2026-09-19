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
                "news_url": "https://example.com/news/test-article",
                "first_published_date": "11/09/2026"
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
        
        let date = try #require(article.publicationDate)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
        let components = calendar.dateComponents(
            [.year, .month, .day],
            from: date
        )
        #expect(components.year == 2026)
        #expect(components.month == 9)
        #expect(components.day == 11)
    }
    
    
    @Test(arguments: ["/news/test-article", ""])
    func rejectsRelativeArticleURL(raw: String) {
        let article = NewsRecord(
            title: "Test Title",
            newsSummary: "  \n",
            categories: "",
            topics:   "",
            newsURL: raw,
            firstPublishedDate: "11/09/2026"
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
            newsURL: "https://example.com/news/test-article",
            firstPublishedDate: "11/09/2026"
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
        "news_url": "https://example.com/news/test-article",
        "first_published_date": "11/09/2026"
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
            newsURL: "https://example.com/news/test-article",
            firstPublishedDate: "11/09/2026"
        )
        
        #expect(article.displaySummary == nil)
    }
    
    @Test func preservesUsefulSummary() {
        let article = NewsRecord(
            title: "Test Title",
            newsSummary: "  Example Summary. ",
            categories: "",
            topics:   "",
            newsURL: "https://example.com/news/test-article",
            firstPublishedDate: "11/09/2026"
        )
        
        #expect(article.displaySummary == "Example Summary.")
    }
    
    @Test(arguments: ["", "31/02/2026", "2026-09-11"])
    func rejectsInvalidPublicationDates(raw: String) {
        let article = NewsRecord(
            title: "Test article",
            newsSummary: "",
            categories: "",
            topics: "",
            newsURL: "https://example.com/news/test-article",
            firstPublishedDate: raw
        )
        
        #expect(article.publicationDate == nil)
    }
    
    
    @Test
    func septemberPublicationIsLaterThanAugust() throws {
        let articleAug = NewsRecord(
            title: "Test article",
            newsSummary: "",
            categories: "",
            topics: "",
            newsURL: "https://example.com/news/test-article",
            firstPublishedDate: "31/08/2026"
        )
        
        let articleSep = NewsRecord(
            title: "Test article",
            newsSummary: "",
            categories: "",
            topics: "",
            newsURL: "https://example.com/news/test-article",
            firstPublishedDate: "01/09/2026"
        )
        
        let dateAug = try #require(articleAug.publicationDate)
        let dateSept = try #require(articleSep.publicationDate)
        
        #expect(dateAug < dateSept)

    }
    
    @Test func sortsNewsNewestFirst() {
        let feed = NewsFeed(data: NewsRecord.samples)
        
        let titles = feed.newestFirst.map { article in
            article.title
        }
        
        #expect(titles == [
            "Sample: September news",
            "Sample: August news",
            "Sample: Another year, July",
            "Sample: Date unavailable"
        ])
    }
    
    @Test func searchesTitleAndSummary() {
        let article = NewsRecord(
            title: "Medicine review",
            newsSummary: "An update about animal health.",
            categories: "Veterinary",
            topics: "Safety",
            newsURL: "https://example.com/news/search-test",
            firstPublishedDate: "11/09/2026"
        )
        
        #expect(article.matchesSearch("MEDICINE"))
        #expect(article.matchesSearch("animal health"))
        #expect(article.matchesSearch("  review  "))
        #expect(article.matchesSearch(""))
        #expect(article.matchesSearch("   "))
        #expect(!article.matchesSearch("conference"))
        #expect(!article.matchesSearch("Veterinary"))
    }
    
    @Test func allModeRequiresEverySelectedCategory() {
        let article = NewsRecord(
            title: "Test article",
            newsSummary: "",
            categories: "Human;Veterinary",
            topics: "",
            newsURL: "https://example.com/news/matching-mode",
            firstPublishedDate: "11/09/2026"
        )
        
        #expect(article.matchesCategories(
            ["Human", "Veterinary"],
            mode: .all
        ))
        
        #expect(!article.matchesCategories(
            ["Human", "Corporate"],
            mode: .all
        ))
        
        #expect(article.matchesCategories(
            ["Human", "Corporate"],
            mode: .any
        ))
        
        #expect(article.matchesCategories(
            ["Human"],
            mode: .all
        ))
        
        #expect(article.matchesCategories(
            [],
            mode: .all
        ))
    }

}
