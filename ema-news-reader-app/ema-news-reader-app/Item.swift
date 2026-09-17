//
//  Item.swift
//  ema-news-reader-app
//
//  Created by christina on 17.09.26.
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
