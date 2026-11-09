//
//  NewsFeedTests.swift
//  ema-news-reader
//
//  Created by christina on 09.11.26.
//

import Testing
import Foundation

@testable import ema_news_reader

struct NewsFeedTests {
    
    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        // Swift Testing Documentation
        // https://developer.apple.com/documentation/testing
    }
    
    @MainActor
    @Test func decodesNewsFeed() throws {
        let json = """
            {
                "meta": { 
                    "total_records": 1,
                    "timestamp": "2026-11-08T18:02:08Z"
                },
                "data": [
                    {
                        "title": "Meeting highlights from the Committee for Veterinary Medicinal Products (CVMP) 3-5 November 2026",
                        "press_release": "No",
                        "related_medicine_referral": "Credelio Quattro;Credelio;Nobivac PLUS DHPPi / Leptos;Laverdia;Scovella",
                        "categories": "Veterinary",
                        "topics": "Medicines",
                        "news_summary": "Outcomes of the Committee for Veterinary Medicinal Products (CVMP) meeting",
                        "first_published_date": "06/11/2026",
                        "last_updated_date": "",
                        "news_url": "https://www.ema.europa.eu/en/news/meeting-highlights-committee-veterinary-medicinal-products-cvmp-3-5-november-2026"
                    }
                ]
            }
        """
        
        let bytes = Data(json.utf8)
        let feed = try JSONDecoder().decode(NewsFeed.self, from: bytes)
        #expect(feed.meta.totalRecords == 1)
        #expect(feed.meta.timestamp == "2026-11-08T18:02:08Z")
        #expect(feed.data.count == 1)
        
        let newsItem = try #require(feed.data.first)
        #expect(newsItem.title == "Meeting highlights from the Committee for Veterinary Medicinal Products (CVMP) 3-5 November 2026")
        #expect(newsItem.categories == "Veterinary")
    }
    
    @MainActor
    @Test func throwsErrorWhenMissingDataInJSON() {
        let json = """
            {
                "meta": { 
                    "total_records": 1,
                    "timestamp": "2026-11-08T18:02:08Z"
                },
                "data": [
                    {
                        "press_release": "No",
                        "related_medicine_referral": "Credelio Quattro;Credelio;Nobivac PLUS DHPPi / Leptos;Laverdia;Scovella",
                        "categories": "Veterinary",
                        "topics": "Medicines",
                        "news_summary": "Outcomes of the Committee for Veterinary Medicinal Products (CVMP) meeting",
                        "first_published_date": "06/11/2026",
                        "last_updated_date": "",
                        "news_url": "https://www.ema.europa.eu/en/news/meeting-highlights-committee-veterinary-medicinal-products-cvmp-3-5-november-2026"
                    }
                ]
            }
        """
        
        let bytes = Data(json.utf8)
        
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(NewsFeed.self, from: bytes)
        }
    }
}
