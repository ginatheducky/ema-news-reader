//
//  NewsCache.swift
//  ema-news-reader
//
//  Created by christina on 29.09.26.
//

import Foundation

actor NewsCache {
    private let fileURL: URL
    
    
    init(fileURL: URL) {
        self.fileURL = fileURL
    }
    
    
    func load() throws -> NewsSnapshot? {
        let data: Data
        
        do {
            data = try Data(contentsOf: fileURL)
        } catch let error as CocoaError where error.code == .fileReadNoSuchFile {
            return nil
        }
        
        return try JSONDecoder().decode(NewsSnapshot.self, from: data)
    }
    
    
    func save(_ snapshot: NewsSnapshot) throws {
        let directory = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(snapshot)
        try data.write(to: fileURL, options: .atomic)
    }

}
