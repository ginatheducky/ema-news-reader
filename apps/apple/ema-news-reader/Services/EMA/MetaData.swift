//
//  MetaData.swift
//  ema-news-reader
//
//  Created by christina on 09.11.26.
//

import Foundation


struct MetaData: Codable {
    let totalRecords: Int
    let timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case totalRecords = "total_records"
        case timestamp
    }
}
