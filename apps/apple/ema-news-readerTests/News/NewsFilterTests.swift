//
//  NewsCategoryFilterTests.swift
//  ema-news-reader
//
//  Created by christina on 12.11.26.
//

import Foundation
import Testing
@testable import ema_news_reader


struct NewsCategoryAndTopicFilterTests {
    @MainActor
    @Test func matchesAnyCategoryWhenOnlyOneSelectedCategoryIsPresent() throws {
        let url = try #require(URL(string: "https://example.com/news/safety-update"))
        
        let item = NewsItem(
            title: "Safety Update",
            pressRelease: false,
            relatedMedicineReferral: [],
            categories: ["Human", "Veterinary"],
            topics: [],
            newsSummary: "New guidance for pharmacies",
            firstPublishedDate: Date(timeIntervalSince1970: 0),
            lastUpdatedDate: nil,
            newsURL: url
        )
        
        #expect(item.matchesAnyCategory(["Human", "Herbal"]) == true)
    }
    
    @MainActor
    @Test func matchesAllCategoriesOnlyWhenEverySelectedCategoryIsPresent() throws {
        let url = try #require(URL(string: "https://example.com/news/safety-update"))
        
        let item = NewsItem(
            title: "Safety Update",
            pressRelease: false,
            relatedMedicineReferral: [],
            categories: ["Human", "Veterinary"],
            topics: [],
            newsSummary: "New guidance for pharmacies",
            firstPublishedDate: Date(timeIntervalSince1970: 0),
            lastUpdatedDate: nil,
            newsURL: url
        )
        
        #expect(item.matchesAllCategories(["Human", "Herbal"]) == false)
        #expect(item.matchesAllCategories(["Human"]) == true)
    }
    
    
    @MainActor
    @Test func matchesAnyTopicWhenOnlyOneSelectedTopicIsPresent() throws {
        let url = try #require(URL(string: "https://example.com/news/safety-update"))
        
        let item = NewsItem(
            title: "Safety Update",
            pressRelease: false,
            relatedMedicineReferral: [],
            categories: ["Human", "Veterinary"],
            topics: ["Safety", "Research"],
            newsSummary: "New guidance for pharmacies",
            firstPublishedDate: Date(timeIntervalSince1970: 0),
            lastUpdatedDate: nil,
            newsURL: url
        )
        
        #expect(item.matchesAnyTopic(["Safety", "Availability"]) == true)
    }
    
    
    @MainActor
    @Test func matchesAllTopicsOnlyWhenEverySelectedTopicIsPresent() throws {
        let url = try #require(URL(string: "https://example.com/news/safety-update"))
        
        let item = NewsItem(
            title: "Safety Update",
            pressRelease: false,
            relatedMedicineReferral: [],
            categories: ["Human", "Veterinary"],
            topics: ["Safety", "Research"],
            newsSummary: "New guidance for pharmacies",
            firstPublishedDate: Date(timeIntervalSince1970: 0),
            lastUpdatedDate: nil,
            newsURL: url
        )
        
        #expect(item.matchesAllTopics(["Safety", "Availability"]) == false)
        #expect(item.matchesAllTopics(["Safety"]) == true)
        #expect(item.matchesAllTopics([]) == true)
    }
    
    @MainActor
    @Test func matchesUsingIndependentCategoryAndTopicModes() throws {
        let url = try #require(URL(string: "https://example.com/news/safety-update"))
        
        let item = NewsItem(
            title: "Safety Update",
            pressRelease: false,
            relatedMedicineReferral: [],
            categories: ["Human"],
            topics: ["Safety"],
            newsSummary: "New guidance for pharmacies",
            firstPublishedDate: Date(timeIntervalSince1970: 0),
            lastUpdatedDate: nil,
            newsURL: url
        )
        
        var filter = NewsFilter()
        
        filter.selectedCategories = ["Human", "Herbal"]
        filter.selectedTopics = ["Safety", "Research"]
        
        filter.categoryMode = .any
        filter.topicMode = .all
        #expect(filter.matches(item) == false)
        
        filter.topicMode = .any
        #expect(filter.matches(item) == true)
    }
    
    @MainActor
    @Test func filtersAndSortsNewestFirstPreservingTies() throws {
        let older = NewsItem(
            title: "Older article",
            pressRelease: false,
            relatedMedicineReferral: [],
            categories: ["Human"],
            topics: ["Safety"],
            newsSummary: "New guidance for pharmacies",
            firstPublishedDate: Date(timeIntervalSince1970: 0),
            lastUpdatedDate: nil,
            newsURL: try #require(URL(string: "https://example.com/news/older"))
        )
        
        let articleB = NewsItem(
            title: "B",
            pressRelease: false,
            relatedMedicineReferral: [],
            categories: ["Human"],
            topics: ["Safety"],
            newsSummary: "New guidance for pharmacies",
            firstPublishedDate: Date(timeIntervalSince1970: 86_400),
            lastUpdatedDate: nil,
            newsURL: try #require(URL(string: "https://example.com/news/B"))
        )
        
        let articleA = NewsItem(
            title: "A",
            pressRelease: false,
            relatedMedicineReferral: [],
            categories: ["Human"],
            topics: ["Safety"],
            newsSummary: "New guidance for pharmacies",
            firstPublishedDate: Date(timeIntervalSince1970: 86_400),
            lastUpdatedDate: nil,
            newsURL: try #require(URL(string: "https://example.com/news/A"))
        )
        
        let newest = NewsItem(
            title: "Newest",
            pressRelease: false,
            relatedMedicineReferral: [],
            categories: ["Veterinary"],
            topics: ["Safety"],
            newsSummary: "New guidance for pharmacies",
            firstPublishedDate: Date(timeIntervalSince1970: 172_800),
            lastUpdatedDate: nil,
            newsURL: try #require(URL(string: "https://example.com/news/newest"))
        )
        
        var filter = NewsFilter()
        filter.selectedCategories = ["Human"]
        
        let results = filter.results(from: [older, articleB, articleA, newest])
        let titles = results.map { item in item.title }
        
        #expect(titles == ["B", "A", "Older article"])
    }
}
