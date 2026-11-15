//
//  NewsFilterPreferencesStore.swift
//  ema-news-reader
//
//  Created by christina on 15.11.26.
//

import Foundation

struct NewsFilterPreferencesStore {
    private let key = "newsFilterPreferences"
    
    func save(_ preferences: NewsFilterPreferences) throws {
        let data = try JSONEncoder().encode(preferences)
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func load() throws -> NewsFilterPreferences? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        
        return try JSONDecoder().decode(NewsFilterPreferences.self, from: data)
    }
}
