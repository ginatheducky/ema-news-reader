//
//  FeedStoreIsolationTests.swift
//  ema-news-reader
//
//  Created by christina on 09.11.26.
//

import Foundation
import Testing

@testable import ema_news_reader

struct FeedStoreIsolationTests {
    @MainActor
    @Test func eventsFailureLeavesOtherFeedsUsable() async throws {
        let newsURL = try #require(URL(string: "https://example.com/news"))
        let eventsURL = try #require(URL(string: "https://example.com/events"))
        let guidelinesURL = try #require(URL(string: "https://example.com/guidelines"))
        
        let newsJSON = """
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
        
        let guidelinesJSON = """
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
                "url": "https://www.ema.europa.eu/en/scientific-guidelines/investigation"
            }
          ]
        }
        """
        
        let client = EMAClient(request: { requestedURL in
            let json: String
            switch requestedURL {
            case newsURL:
                json = newsJSON
            case eventsURL:
                throw URLError(.notConnectedToInternet)
            case guidelinesURL:
                json = guidelinesJSON
            default:
                throw URLError(.badURL)
            }
            
            let response = try #require(HTTPURLResponse(
                url: requestedURL,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            ))
            return (Data(json.utf8), response)
        })
        
        let news = NewsStore(loader: NewsFeedLoader(client: client))
        let events = EventsStore(loader: EventsFeedLoader(client: client))
        let guidelines = GuidelinesStore(loader: GuidelinesFeedLoader(client: client))
        
        await news.refresh(from: newsURL)
        await events.refresh(from: eventsURL)
        await guidelines.refresh(from: guidelinesURL)
        
        #expect(news.feed?.items.first?.title == "Example news")
        #expect(guidelines.feed?.items.first?.title == "Investigation of bioequivalence")
        #expect(events.feed == nil)
        #expect((events.lastError as? URLError)?.code == .notConnectedToInternet)
        #expect(news.lastError == nil)
        #expect(guidelines.lastError == nil)
        
    }
}
