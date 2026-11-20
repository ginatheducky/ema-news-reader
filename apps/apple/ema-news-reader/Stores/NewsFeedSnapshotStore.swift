//
//  NewsFeedSnapshotStore.swift
//  ema-news-reader
//
//  Created by christina on 15.11.26.
//

import Foundation

struct NewsFeedSnapshotStore {
    let fileURL: URL
    
    static func inApplicationSupport() throws -> NewsFeedSnapshotStore {
        let directory = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        
        return NewsFeedSnapshotStore(fileURL: directory.appendingPathComponent("news-snapshot.json"))
    }
    
    enum SnapshotError: Error, Equatable {
        case unsupportedVersion(Int)
    }
    
    func save(_ snapshot: NewsFeedSnapshot) throws {
        // protect the saved file from an older snapshot by checking if existing snapshot is newer
        do {
            if let existingSnapshot = try load(), existingSnapshot.lastSuccessfulCheck > snapshot.lastSuccessfulCheck {
                return
            }
        } catch is DecodingError {
            // continue so the atomic write can replace the unreadable snapshot
            // the atomic write below will replace the corrupt snapshot
            
        }
        
        // encode the snapshot into data
        let data = try JSONEncoder().encode(snapshot)
        
        // write the data to fileURL
        try data.write(to: fileURL, options: .atomic)
    }
    
    func load() throws -> NewsFeedSnapshot? {
        let data: Data
        
        do {
            data = try Data(contentsOf: fileURL)
        } catch let error as CocoaError where error.code == .fileReadNoSuchFile {
            return nil
        }
        
        let snapshot = try JSONDecoder().decode(NewsFeedSnapshot.self, from: data)
        
        guard snapshot.schemaVersion == 1 else {
            throw SnapshotError.unsupportedVersion(snapshot.schemaVersion)
        }
        
        return snapshot
    }
}
