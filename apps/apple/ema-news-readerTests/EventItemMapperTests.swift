//
//  EventItemMapperTests.swift
//  ema-news-reader
//
//  Created by christina on 09.11.26.
//

import Testing
@testable import ema_news_reader

struct EventItemMapperTests {
    @MainActor
    @Test func mapsFlagsAndPreservesScheduleText() throws {
        let schedule = "Thu, Jan 14 2027, 2 - 3pm"
        let record = EventRecord(
            title: "EudraGMDP Q&A clinic for public users",
            dateStartEndDates: schedule,
            liveBroadcast: "No",
            online: "Yes",
            location: "",
            firstPublishedDate: "04/11/2026",
            lastUpdatedDate: "",
            eventURL: "https://www.ema.europa.eu/en/events/example"
        )
        
        let item = try #require(EventItemMapper.map(record))
        
        #expect(item.dateStartEndDates == schedule)
        #expect(item.liveBroadcast == false)
        #expect(item.online == true)
        #expect(item.location == nil)
        #expect(item.lastUpdatedDate == nil)
    }
}
