//
//  ema_news_readerTests.swift
//  ema-news-readerTests
//
//  Created by christina on 26.09.26.
//

import Testing
import Foundation
@testable import ema_news_reader


struct ema_news_reader_appTests {
    
    @Test func acceptsSuccessfulNewsResponse() throws {
        let url = try #require(URL(string: "https://example.com/news"))
        
        let response = try #require(HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        ))
        
        let data = Data(#"{"data":[]}"#.utf8)
        
        let feed = try NewsService.decodeResponse(
            data: data,
            response: response
        )
        
        #expect(feed.data.isEmpty)
    }
    
    @Test func rejectsMalformedSuccessfulResponse() throws {
        let url = try #require(URL(string: "https://example.com/news"))
        
        let response = try #require(HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        ))
        
        let data = Data("not JSON".utf8)
        
        #expect(throws: DecodingError.self) {
            _ = try NewsService.decodeResponse(
                data: data,
                response: response
            )
        }
    }
    
    @Test func rejectsServerErrorBeforeDecoding() throws {
        let url = try #require(URL(string: "https://example.com/news"))
        
        let response = try #require(HTTPURLResponse(
            url: url,
            statusCode: 503,
            httpVersion: nil,
            headerFields: nil
        ))
        
        #expect(throws: NewsServiceError.unsuccessfulStatus(503)) {
            _ = try NewsService.decodeResponse(
                data: Data(),
                response: response
            )
        }
    }
    
    @MainActor
    @Test func storeLoadsArticles() async {
        let expected = NewsFeed(data: NewsRecord.samples).newestFirst
        let store = NewsStore(loadArticles: { expected })
        
        #expect(store.articles == nil)
        
        await store.loadNews()
        
        #expect(store.articles?.map(\.newsURL) == expected.map(\.newsURL))
        #expect(!store.isLoading)
        #expect(store.errorMessage == nil)
    }
    
    @MainActor
    @Test func storeReportsLoadingFailure() async {
        let store = NewsStore(loadArticles: {
            throw NewsServiceError.unsuccessfulStatus(503)
        })
        
        await store.loadNews()
        
        #expect(store.articles == nil)
        #expect(!store.isLoading)
        #expect(store.errorMessage != nil)
    }
    
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
            "Sample: August2 news",
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
    
    @Test func combinesSearchCategoriesAndTopics() {
        let article = NewsRecord(
            title: "Medicine review",
            newsSummary: "An update about treatment.",
            categories: "Human;Veterinary",
            topics: "Innovation;Medicines",
            newsURL: "https://example.com/news/combined-filters",
            firstPublishedDate: "11/09/2026"
        )
        
        #expect(article.matchesFilters(
            query: "review",
            categories: ["Human", "Veterinary"],
            categoryMode: .all,
            topics: ["Medicines", "Innovation"],
            topicMode: .all
        ))
        
        #expect(!article.matchesFilters(
            query: "review",
            categories: ["Human", "Veterinary"],
            categoryMode: .all,
            topics: ["Safety"],
            topicMode: .all
        ))
        
        #expect(!article.matchesFilters(
            query: "test",
            categories: ["Human", "Veterinary"],
            categoryMode: .all,
            topics: ["Innovation"],
            topicMode: .all
        ))
        
        #expect(article.matchesFilters(
            query: "",
            categories: [],
            categoryMode: .all,
            topics: [],
            topicMode: .all
        ))
    }
    
    @MainActor
    @Test
    func loadIfNeededDoesNotRepeatSuccessfulEmptyLoad() async {
        var loadCount = 0
        
        let store = NewsStore(loadArticles: {
            loadCount += 1
            return []
        })
        
        await store.loadIfNeeded()
        await store.loadIfNeeded()
        
        #expect(loadCount == 1)
        #expect(store.articles?.isEmpty == true)
    }
    
    @MainActor
    @Test
    func failedRefreshKeepsExistingArticles() async {
        let expected = NewsFeed(data: NewsRecord.samples).newestFirst
        var loadCount = 0
        
        let store = NewsStore(loadArticles: {
            loadCount += 1
            
            if loadCount == 1 {
                return expected
            }
            
            throw NewsServiceError.unsuccessfulStatus(503)
        })
        
        await store.loadNews()
        await store.loadNews()
        
        #expect(loadCount == 2)
        #expect(store.articles?.map(\.newsURL) == expected.map(\.newsURL))
        #expect(store.errorMessage != nil)
        #expect(!store.isLoading)
    }
    
    @MainActor
    @Test
    func successfulRefreshUpdatesTimestamp() async {
        let firstTime = Date(timeIntervalSince1970: 1_000)
        let secondTime = Date(timeIntervalSince1970: 2_000)
        var currentTime = firstTime
        
        let store = NewsStore(
            now: { currentTime },
            loadArticles: { [] }
        )
        
        #expect(store.lastSuccessfulRefresh == nil)
        
        await store.loadNews()
        #expect(store.lastSuccessfulRefresh == firstTime)
        
        currentTime = secondTime
        
        await store.loadNews()
        #expect(store.lastSuccessfulRefresh == secondTime)
    }
    
    @MainActor
    @Test
    func failedRefreshPreservesTimestamp() async {
        let successfulTime = Date(timeIntervalSince1970: 1_000)
        var currentTime = successfulTime
        var shouldFail = false
        
        let store = NewsStore(
            now: { currentTime },
            loadArticles: {
                if shouldFail {
                    throw NewsServiceError.unsuccessfulStatus(503)
                }
                
                return []
            }
        )
        
        await store.loadNews()
        #expect(store.lastSuccessfulRefresh == successfulTime)
        
        currentTime = Date(timeIntervalSince1970: 2_000)
        shouldFail = true
        
        await store.loadNews()
        
        #expect(store.lastSuccessfulRefresh == successfulTime)
        #expect(store.errorMessage != nil)
        #expect(!store.isLoading)
    }
    
    @MainActor
    @Test
    func markingArticleReadDoesNotCreateDuplicates() {
        let article = NewsRecord.samples[0]
        let store = NewsStore(preferences: nil)
        
        store.markAsRead(article)
        store.markAsRead(article)
        
        #expect(store.readArticleURLs == Set([article.newsURL]))
    }
    
    @MainActor
    @Test
    func readStatusSurvivesCreatingAnotherStore() throws {
        let suiteName = "ReadStatusTests.\(UUID().uuidString)"
        let preferences = try #require(
            UserDefaults(suiteName: suiteName)
        )
        
        defer {
            preferences.removePersistentDomain(forName: suiteName)
        }
        
        let article = NewsRecord.samples[0]
        let firstStore = NewsStore(preferences: preferences)
        
        firstStore.markAsRead(article)
        
        let secondStore = NewsStore(preferences: preferences)
        
        #expect(secondStore.readArticleURLs.contains(article.newsURL))
    }
    
    @MainActor
    @Test
    func newBadgesRemainUntilAnotherAdditionBatch() async {
        let a = NewsRecord.samples[0]
        let b = NewsRecord.samples[1]
        let c = NewsRecord.samples[2]
        
        var response = [a]
        
        let store = NewsStore(
            preferences: nil,
            loadArticles: { response }
        )
        
        await store.loadNews()
        #expect(store.newArticleURLs.isEmpty)
        
        response = [a, b]
        await store.loadNews()
        #expect(store.newArticleURLs == Set([b.newsURL]))
        
        let editedA = NewsRecord(
            title: a.title + " — corrected",
            newsSummary: a.newsSummary,
            categories: a.categories,
            topics: a.topics,
            newsURL: a.newsURL,
            firstPublishedDate: a.firstPublishedDate
        )
        
        // Editing an existing article preserves B's badge.
        response = [editedA, b]
        await store.loadNews()
        #expect(store.newArticleURLs == Set([b.newsURL]))
        
        // Another addition batch replaces B with C.
        response = [editedA, b, c]
        await store.loadNews()
        #expect(store.newArticleURLs == Set([c.newsURL]))
        
        // Removing an unrelated article preserves C's badge.
        response = [editedA, c]
        await store.loadNews()
        #expect(store.newArticleURLs == Set([c.newsURL]))
        
        // Removing C removes its badge.
        response = [editedA]
        await store.loadNews()
        #expect(store.newArticleURLs.isEmpty)
    }
    
    @MainActor
    @Test
    func readingArticleRemovesNewBadge() async {
        let a = NewsRecord.samples[0]
        let b = NewsRecord.samples[1]
        var response = [a]
        
        let store = NewsStore(
            preferences: nil,
            loadArticles: { response }
        )
        
        await store.loadNews()
        
        response = [a, b]
        await store.loadNews()
        #expect(store.newArticleURLs.contains(b.newsURL))
        
        store.markAsRead(b)
        
        #expect(!store.newArticleURLs.contains(b.newsURL))
        #expect(store.readArticleURLs.contains(b.newsURL))
        
        // An identical download must not restore the badge.
        await store.loadNews()
        #expect(!store.newArticleURLs.contains(b.newsURL))
    }
    
}
