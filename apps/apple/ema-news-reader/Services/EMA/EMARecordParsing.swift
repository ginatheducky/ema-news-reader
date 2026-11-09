//
//  EMARecordParsing.swift
//  ema-news-reader
//
//  Created by christina on 09.11.26.
//

import Foundation

/// Shared parsing rules for values in EMA feed records.
///
/// The News, Events, and Guidelines mappers use these rules when
/// converting decoded records into app models.

enum EMARecordParsing {
    
    /// Parses a source link as an absolute HTTPS URL with a nonempty host.
    ///
    /// - Parameter value: The URL string supplied by the EMA feed.
    /// - Returns: The parsed URL, or `nil` if the value fails validation.
    static func httpsURL(from value: String) -> URL? {
        guard let url = URL(string: value),
              url.scheme?.lowercased() == "https",
              let host = url.host,
              !host.isEmpty else {
            return nil
        }
        
        return url
    }
}
