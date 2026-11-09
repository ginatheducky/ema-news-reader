//
//  NewsItem.swift
//  ema-news-reader
//
//  Created by christina on 09.11.26.
//

import Foundation

struct NewsItem {
    let title: String
    let pressRelease: Bool
    let relatedMedicineReferral: [String]
    let categories: [String]
    let topics: [String]
    let newsSummary: String
    let firstPublishedDate: Date
    let lastUpdatedDate: Date?
    let newsURL: URL
}

