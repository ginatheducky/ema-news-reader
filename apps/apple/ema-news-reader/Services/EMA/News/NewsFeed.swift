//
//  NewsFeed.swift
//  ema-news-reader
//
//  Created by christina on 08.11.26.
//


import Foundation


struct NewsFeed: Decodable {
    let data: [NewsRecord]
    let meta: MetaData
}

struct NewsRecord: Codable {
    let title: String
    let pressRelease: String
    let relatedMedicineReferral: String
    let categories: String
    let topics: String
    let newsSummary: String
    let firstPublishedDate: String
    let lastUpdatedDate: String
    let newsURL: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case pressRelease = "press_release"
        case relatedMedicineReferral = "related_medicine_referral"
        case categories
        case topics
        case newsSummary = "news_summary"
        case firstPublishedDate = "first_published_date"
        case lastUpdatedDate = "last_updated_date"
        case newsURL = "news_url"
    }
}
