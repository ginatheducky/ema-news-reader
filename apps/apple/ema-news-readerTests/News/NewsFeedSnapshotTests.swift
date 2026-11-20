//
//  NewsFeedSnapshotTests.swift
//  ema-news-reader
//
//  Created by christina on 15.11.26.
//

import Foundation
import Testing
@testable import ema_news_reader

struct NewsFeedSnapshotTests {
    
    @MainActor
    @Test func roundTripsNewsFeedSnapshot() throws {
        let item = NewsItem(
            title: "Older article",
            pressRelease: false,
            relatedMedicineReferral: [],
            categories: ["Human"],
            topics: ["Safety"],
            newsSummary: nil,
            firstPublishedDate: Date(timeIntervalSince1970: 0),
            lastUpdatedDate: nil,
            newsURL: try #require(URL(string: "https://example.com/news/older"))
        )
        
        let snapshot = NewsFeedSnapshot(
            items: [item],
            exportTimestamp: "2026-11-08T18:02:08Z",
            lastSuccessfulCheck: Date(timeIntervalSince1970: 0)
        )
        
        let data = try JSONEncoder().encode(snapshot)
        let restored = try JSONDecoder().decode(NewsFeedSnapshot.self, from: data)
        
        #expect(restored.schemaVersion == snapshot.schemaVersion)
        #expect(restored.exportTimestamp == snapshot.exportTimestamp)
        #expect(restored.lastSuccessfulCheck == snapshot.lastSuccessfulCheck)
        #expect(restored.items.count == 1)
        
        let restoredArticle = try #require(restored.items.first)
        
        #expect(restoredArticle.title == "Older article")
        #expect(restoredArticle.newsURL == URL(string: "https://example.com/news/older"))
        #expect(restoredArticle.newsSummary == nil)
        
    }
    
    
    @MainActor
    @Test func rejectsUnsupportedSnapshotVersion() throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("news-snapshot-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: fileURL) }
        
        let store = NewsFeedSnapshotStore(fileURL: fileURL)
        let snapshot = NewsFeedSnapshot(
            schemaVersion: 2,
            items: [],
            exportTimestamp: "2026-11-08T18:02:08Z",
            lastSuccessfulCheck: Date(timeIntervalSince1970: 0)
        )
        
        try store.save(snapshot)
        
        #expect(throws: NewsFeedSnapshotStore.SnapshotError.unsupportedVersion(2)) {
            try store.load()
        }
    }
    
    @MainActor
    @Test func returnsNilWhenSnapshotFileIsMissing() throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("news-snapshot-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: fileURL) }
        
        let store = NewsFeedSnapshotStore(fileURL: fileURL)
        let snapshot = try store.load()
        #expect(snapshot == nil)
    }
    
    @MainActor
    @Test func loadsSavedVersionOneSnapshot() throws {
        let item = NewsItem(
            title: "Older article",
            pressRelease: false,
            relatedMedicineReferral: [],
            categories: ["Human"],
            topics: ["Safety"],
            newsSummary: nil,
            firstPublishedDate: Date(timeIntervalSince1970: 0),
            lastUpdatedDate: nil,
            newsURL: try #require(URL(string: "https://example.com/news/older"))
        )
        
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("news-snapshot-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: fileURL) }
        
        let store = NewsFeedSnapshotStore(fileURL: fileURL)
        let snapshot = NewsFeedSnapshot(
            schemaVersion: 1,
            items: [item],
            exportTimestamp: "2026-11-08T18:02:08Z",
            lastSuccessfulCheck: Date(timeIntervalSince1970: 0)
        )
        
        try store.save(snapshot)
        
        let loadedSnapshot = try store.load()
        let restored = try #require(loadedSnapshot)
        
        #expect(restored.schemaVersion == snapshot.schemaVersion)
        #expect(restored.exportTimestamp == snapshot.exportTimestamp)
        #expect(restored.lastSuccessfulCheck == snapshot.lastSuccessfulCheck)
        #expect(restored.items.count == 1)
        
        let restoredItem = try #require(restored.items.first)
        #expect(restoredItem.title == item.title)
    }
    
    
    @MainActor
    @Test func throwsWhenSnapshotFileContainsInvalidJSON() throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("news-snapshot-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: fileURL) }
        
        try Data("not JSON".utf8).write(to: fileURL)
        let store = NewsFeedSnapshotStore(fileURL: fileURL)
        
        #expect(throws: DecodingError.self) {
            try store.load()
        }
    }
    
    
    @MainActor
    @Test func throwsWhenSnapshotParentDirectoryIsMissing() {
        let missingDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("missing-\(UUID().uuidString)", isDirectory: true)
        let fileURL = missingDirectory.appendingPathComponent("news-snapshot.json")
        defer { try? FileManager.default.removeItem(at: missingDirectory) }
        
        let store = NewsFeedSnapshotStore(fileURL: fileURL)
        let snapshot = NewsFeedSnapshot(
            schemaVersion: 1,
            items: [],
            exportTimestamp: "2026-11-08T18:02:08Z",
            lastSuccessfulCheck: Date(timeIntervalSince1970: 0)
        )
        
        #expect(throws: CocoaError.self) {
            try store.save(snapshot)
        }
    }
    
    @MainActor
    @Test func keepsNewerSnapshotWhenOlderSnapshotIsSavedLater() throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("news-snapshot-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: fileURL) }
        
        let store = NewsFeedSnapshotStore(fileURL: fileURL)
        
        let newerSnapshot = NewsFeedSnapshot(
            schemaVersion: 1,
            items: [],
            exportTimestamp: "2026-11-08T18:02:08Z",
            lastSuccessfulCheck: Date(timeIntervalSince1970: 300)
        )
        
        let olderSnapshot = NewsFeedSnapshot(
            schemaVersion: 1,
            items: [],
            exportTimestamp: "2026-11-08T18:02:08Z",
            lastSuccessfulCheck: Date(timeIntervalSince1970: 100)
        )
        
        try store.save(newerSnapshot)
        try store.save(olderSnapshot)
        
        let loadedSnapshot = try store.load()
        let restored = try #require(loadedSnapshot)
        
        #expect(restored.lastSuccessfulCheck == newerSnapshot.lastSuccessfulCheck)
    }

    @MainActor
    @Test func freshSnapshotReplacesAcorruptJSONfile() throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("news-snapshot-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: fileURL) }
        
        try Data("not JSON".utf8).write(to: fileURL)
        let store = NewsFeedSnapshotStore(fileURL: fileURL)
        
        #expect(throws: DecodingError.self) {
            try store.load()
        }
        
        let snapshot = NewsFeedSnapshot(
            schemaVersion: 1,
            items: [],
            exportTimestamp: "2026-11-08T18:02:08Z",
            lastSuccessfulCheck: Date(timeIntervalSince1970: 0)
        )
        try store.save(snapshot)
        
        let loadedSnapshot = try store.load()
        let restored = try #require(loadedSnapshot)
        
        #expect(restored.lastSuccessfulCheck == snapshot.lastSuccessfulCheck)
    }
}

