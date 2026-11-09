//
//  EventsFeedTest.swift
//  ema-news-reader
//
//  Created by christina on 09.11.26.
//

import Foundation
import Testing
@testable import ema_news_reader

struct EventsFeedTests {
    @MainActor
    @Test func decodesEventWithEmptyLocationAndUpdateDate() throws {
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
        
        let feed = try JSONDecoder().decode(EventsFeed.self, from: Data(json.utf8))
        let event = try #require(feed.data.first)
        
        #expect(event.dateStartEndDates == "Thu, Jan 14 2027, 2 - 3pm")
        #expect(event.location.isEmpty)
        #expect(event.lastUpdatedDate.isEmpty)
        #expect(event.online == "Yes")
    }
}
