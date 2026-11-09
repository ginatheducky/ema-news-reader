//
//  EventItem.swift
//  ema-news-reader
//
//  Created by christina on 09.11.26.
//

import Foundation

struct EventItem {
    let title: String
    let dateStartEndDates: String
    let liveBroadcast: Bool
    let online: Bool
    let location: String?
    let firstPublishedDate: Date
    let lastUpdatedDate: Date?
    let eventURL: URL
}
