//
//  NewsFeedLoaderTests.swift
//  ema-news-reader
//
//  Created by christina on 09.11.26.
//

import Foundation
import Testing
@testable import ema_news_reader

struct NewsFeedLoaderTests {
    @MainActor
    @Test func loadsItemsAndPreservesMetadata() async throws {
        let url = try #require(URL(string: "https://example.com/news"))
        let json = """
        {
          "meta": {
            "total_records": 1,
            "timestamp": "2026-11-08T18:02:08Z"
          },
          "data": [
            {
              "title": "Example news",
              "press_release": "Yes",
              "related_medicine_referral": "",
              "categories": "Veterinary; Human",
              "topics": "",
              "news_summary": "Example summary",
              "first_published_date": "06/11/2026",
              "last_updated_date": "",
              "news_url": "https://www.ema.europa.eu/en/news/example"
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
        let loader = NewsFeedLoader(client: client)
        
        let loaded = try await loader.load(from: url)
        
        #expect(loaded.meta.timestamp == "2026-11-08T18:02:08Z")
        #expect(loaded.items.count == 1)
        
        let item = try #require(loaded.items.first)
        #expect(item.categories == ["Veterinary", "Human"])
    }
    
    
    @MainActor
    @Test func keepsValidItemWhenAnotherRecordHasRelativeURL() async throws {
        let url = try #require(URL(string: "https://example.com/news"))
        let json = """
        {
          "meta": {
            "total_records": 2,
            "timestamp": "2026-11-08T18:02:08Z"
          },
          "data": [
            {
              "title": "Example news",
              "press_release": "Yes",
              "related_medicine_referral": "",
              "categories": "Veterinary; Human",
              "topics": "",
              "news_summary": "Example summary",
              "first_published_date": "06/11/2026",
              "last_updated_date": "",
              "news_url": "https://www.ema.europa.eu/en/news/example"
            },
            {
              "title": "Record with relative URL",
              "press_release": "Yes",
              "related_medicine_referral": "",
              "categories": "Veterinary; Human",
              "topics": "",
              "news_summary": "Example summary",
              "first_published_date": "06/11/2026",
              "last_updated_date": "",
              "news_url": "/en/news/rejected"
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
        let loader = NewsFeedLoader(client: client)
        
        let loaded = try await loader.load(from: url)
        
        #expect(loaded.meta.totalRecords == 2)
        #expect(loaded.items.count == 1)
        
        let item = try #require(loaded.items.first)
        #expect(item.title == "Example news")
    }
    
    @MainActor
    @Test func rejectsFeedWhenAllRecordsAreUnusable() async throws {
        let url = try #require(URL(string: "https://example.com/news"))
        let json = """
        {
          "meta": {
            "total_records": 1,
            "timestamp": "2026-11-08T18:02:08Z"
          },
          "data": [
            {
              "title": "Example news",
              "press_release": "Yes",
              "related_medicine_referral": "",
              "categories": "Veterinary; Human",
              "topics": "",
              "news_summary": "Example summary",
              "first_published_date": "06/11/2026",
              "last_updated_date": "",
              "news_url": "/en/news/rejected"
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
        let loader = NewsFeedLoader(client: client)
        
        await #expect(throws: NewsFeedLoaderError.noUsableRecords) {
            try await loader.load(from: url)
        }
    }
    
    
    @MainActor
    @Test func rejectsMalformedJSON() async throws {
        let url = try #require(URL(string: "https://example.com/news"))
        let json = "{"
        
        let response = try #require(HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        ))
        let client = EMAClient(request: { _ in
            (Data(json.utf8), response)
        })
        let loader = NewsFeedLoader(client: client)
        
        await #expect(throws: DecodingError.self) {
            try await loader.load(from: url)
        }
    }
    
    @MainActor
    @Test func acceptsEmptyFeed() async throws {
        let url = try #require(URL(string: "https://example.com/news"))
        let json = """
            {
              "meta": {
                "total_records": 0,
                "timestamp": "2026-11-08T18:02:08Z"
              },
              "data": []
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
        let loader = NewsFeedLoader(client: client)
        let loaded = try await loader.load(from: url)
        
        #expect(loaded.items.isEmpty)
        #expect(loaded.meta.totalRecords == 0)
    }
    
}
