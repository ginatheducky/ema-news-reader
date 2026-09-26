//
//  Item.swift
//  ema-news-reader
//
//  Created by christina on 26.09.26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
