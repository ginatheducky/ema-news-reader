//
//  GuidelinesFeedLoaderTests.swift
//  ema-news-reader
//
//  Created by christina on 09.11.26.
//

import Foundation
import Testing
@testable import ema_news_reader

struct GuidelinesFeedLoaderTests {
    @MainActor
    @Test func loadsGuidelinesAndPreservesMetadata() async throws {
        let url = try #require(URL(string: "https://example.com/guidelines"))
        let json = """
        {
          "meta": {
            "total_records": 1,
            "timestamp": "2026-11-08T18:00:20Z"
          },
          "data": [
            {
                "title": "Investigation of bioequivalence",
                "category": "Human; ",
                "first_published_date": "29/01/2010",
                "last_updated_date": "",
                "url": "https://www.ema.europa.eu/en/scientific-guidelines/investigation-bioequivalence"
            }
          ]
        }
        """
        
        let response = try #require(HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        ))
        let client = EMAClient(request: { _ in
            (Data(json.utf8), response)
        })
        let loader = GuidelinesFeedLoader(client: client)
        
        let loaded = try await loader.load(from: url)
        
        #expect(loaded.meta.timestamp == "2026-11-08T18:00:20Z")
        #expect(loaded.items.count == 1)
        
        let guideline = try #require(loaded.items.first)
        
        #expect(guideline.category == ["Human"])
        #expect(guideline.lastUpdatedDate == nil)
        #expect(guideline.title == "Investigation of bioequivalence")
    }
    
    @MainActor
    @Test func rejectsRelativeUrl() async throws {
        let url = try #require(URL(string: "https://example.com/guidelines"))
        let json = """
        {
          "meta": {
            "total_records": 1,
            "timestamp": "2026-11-08T18:00:20Z"
          },
          "data": [
            {
                "title": "Investigation of bioequivalence",
                "category": "Human; ",
                "first_published_date": "29/01/2010",
                "last_updated_date": "",
                "url": "/en/scientific-guidelines/example"
            }
          ]
        }
        """
        
        let response = try #require(HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        ))
        let client = EMAClient(request: { _ in
            (Data(json.utf8), response)
        })
        let loader = GuidelinesFeedLoader(client: client)
        
        await #expect(throws: GuidelinesFeedLoaderError.noUsableRecords) {
            try await loader.load(from: url)
        }
    }
    
}
