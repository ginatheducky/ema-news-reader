//
//  NewsSearchTests.swift
//  ema-news-reader
//
//  Created by christina on 12.11.26.
//


import Foundation
import Testing
@testable import ema_news_reader

struct NewsSearchTests {
    @MainActor
    @Test func doesNotMatchWhenNeitherTitleNorSummaryContainsQuery() throws {
        let url = try #require(URL(string: "https://example.com/news/safety-update"))
        
        let item = NewsItem(
            title: "Safety Update",
            pressRelease: false,
            relatedMedicineReferral: [],
            categories: [],
            topics: [],
            newsSummary: "New guidance for pharmacies",
            firstPublishedDate: Date(timeIntervalSince1970: 0),
            lastUpdatedDate: nil,
            newsURL: url
        )
        
        #expect(item.matchesSearch("cafe") == false)
    }
    
    @MainActor
    @Test func matchesSummaryWhenTitleDoesNotMatch() throws {
        let url = try #require(URL(string: "https://example.com/news/safety-update"))
        
        let item = NewsItem(
            title: "Safety Update",
            pressRelease: false,
            relatedMedicineReferral: [],
            categories: [],
            topics: [],
            newsSummary: "New guidance for café operators",
            firstPublishedDate: Date(timeIntervalSince1970: 0),
            lastUpdatedDate: nil,
            newsURL: url
        )
        
        #expect(item.matchesSearch("  CAFE   ") == true)
    }
    
    @MainActor
    @Test func matchesTitleWhenSummaryIsMissing() throws {
        let url = try #require(URL(string: "https://example.com/news/safety-update"))
        
        let item = NewsItem(
            title: "Café safety update",
            pressRelease: false,
            relatedMedicineReferral: [],
            categories: [],
            topics: [],
            newsSummary: nil,
            firstPublishedDate: Date(timeIntervalSince1970: 0),
            lastUpdatedDate: nil,
            newsURL: url
        )
        
        #expect(item.matchesSearch("  CAFE   ") == true)
    }
    
    @MainActor
    @Test func matchesWhenQueryIsOnlyWhitespace() throws {
        let url = try #require(URL(string: "https://example.com/news/safety-update"))
        
        let item = NewsItem(
            title: "Safety update",
            pressRelease: false,
            relatedMedicineReferral: [],
            categories: [],
            topics: [],
            newsSummary: nil,
            firstPublishedDate: Date(timeIntervalSince1970: 0),
            lastUpdatedDate: nil,
            newsURL: url
        )
        
        #expect(item.matchesSearch("  \n\t ") == true)
    }
}
