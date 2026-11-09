//
//  GuidelinesFeed.swift
//  ema-news-reader
//
//  Created by christina on 09.11.26.
//


import Foundation


struct GuidelinesFeed: Decodable {
    let data: [GuidelineRecord]
    let meta: MetaData
}

struct GuidelineRecord: Codable {
    let title: String
    let category: String
    let firstPublishedDate: String
    let lastUpdatedDate: String
    let guidelineURL: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case category
        case firstPublishedDate = "first_published_date"
        case lastUpdatedDate = "last_updated_date"
        case guidelineURL = "url"
    }
}
