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
        
        #expect(item.matchesAllTopics(["Safety", "Corporate"]) == false)
        #expect(item.matchesAllTopics(["Safety"]) == true)
    }
}
