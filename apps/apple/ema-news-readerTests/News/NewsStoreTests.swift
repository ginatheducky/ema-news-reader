//
//  NewsStoreTests.swift
//  ema-news-reader
//
//  Created by christina on 09.11.26.
//

import Foundation
import Testing
@testable import ema_news_reader

struct NewsStoreTests {
    @MainActor
    @Test func keepsPreviousFeedWhenRefreshFails() async throws {
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
              "categories": "Veterinary; Human; ",
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
        
        let failingURL = try #require(URL(string: "https://example.com/offline"))
        let client = EMAClient(request: { requestedURL in
            if requestedURL == failingURL {
                throw URLError(.notConnectedToInternet)
            }
            return (Data(json.utf8), response)
        })
        
        let firstCheck = Date(timeIntervalSince1970: 1_000)
        var currentTime = firstCheck
        
        let store = NewsStore(loader: NewsFeedLoader(client: client), now: { currentTime })
        
        await store.refresh(from: url)
        
        let originalItem = try #require(store.feed?.items.first)
        #expect(store.lastError == nil)
        #expect(store.lastSuccessfulCheck == firstCheck)
        
        currentTime = firstCheck.addingTimeInterval(60)
        await store.refresh(from: failingURL)
        
        #expect(store.feed?.items.first?.title == originalItem.title)
        #expect((store.lastError as? URLError)?.code == .notConnectedToInternet)
        #expect(!store.isLoading)
        #expect(store.lastSuccessfulCheck == firstCheck)
    }
    
    
    @MainActor
    @Test func showsLoadingWhileFirstRefreshIsInFlight() async throws {
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
              "categories": "Veterinary; Human; ",
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
        
        let requestStarted = AsyncStream<Void>.makeStream()
        let allowResponse = AsyncStream<Void>.makeStream()
        
        let client = EMAClient(request: { _ in
            requestStarted.continuation.yield(())
            
            var release = allowResponse.stream.makeAsyncIterator()
            _ = await release.next()
            
            return (Data(json.utf8), response)
        })
        let store = NewsStore(loader: NewsFeedLoader(client: client))
        
        let refresh = Task {
            await store.refresh(from: url)
        }
        
        var started = requestStarted.stream.makeAsyncIterator()
        _ = await started.next()
        
        #expect(store.isLoading)
        #expect(store.feed == nil)
        
        allowResponse.continuation.yield(())
        await refresh.value
        
        #expect(!store.isLoading)
        #expect(store.feed?.items.first?.title == "Example news")
    }

}
