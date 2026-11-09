//
//  EventsFeedLoaderTests.swift
//  ema-news-reader
//
//  Created by christina on 09.11.26.
//

import Foundation
import Testing
@testable import ema_news_reader

struct EventsFeedLoaderTests {
    @MainActor
    @Test func loadsEventsAndPreservesMetadata() async throws {
        let url = try #require(URL(string: "https://example.com/events"))
        let json = """
        {
          "meta": {
            "total_records": 1,
            "timestamp": "2026-11-08T18:00:20Z"
          },
          "data": [
            {
              "title": "EudraGMDP Q&A clinic for public users",
              "date_start_end_dates": "Thu, Jan 14 2027, 2 - 3pm",
              "live_broadcast": "No",
              "online": "Yes",
              "location": "",
              "first_published_date": "04/11/2026",
              "last_updated_date": "",
              "event_url": "https://www.ema.europa.eu/en/events/eudragmdp-qa-clinic-public-users"
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
        let loader = EventsFeedLoader(client: client)
        
        let loaded = try await loader.load(from: url)
        
        #expect(loaded.meta.timestamp == "2026-11-08T18:00:20Z")
        #expect(loaded.items.count == 1)
        
        let event = try #require(loaded.items.first)
        #expect(event.dateStartEndDates == "Thu, Jan 14 2027, 2 - 3pm")
        #expect(event.online)
    }
        
}
