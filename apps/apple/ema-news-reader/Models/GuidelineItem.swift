//
//  GuidelineItem.swift
//  ema-news-reader
//
//  Created by christina on 09.11.26.
//

import Foundation

struct GuidelineItem {
    let title: String
    let category: [String]
    let firstPublishedDate: Date
    let lastUpdatedDate: Date?
    let guidelineURL: URL
}
