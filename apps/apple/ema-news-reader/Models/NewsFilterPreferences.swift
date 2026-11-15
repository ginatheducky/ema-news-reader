//
//  NewsFilterPreferences.swift
//  ema-news-reader
//
//  Created by christina on 14.11.26.
//

struct NewsFilterPreferences: Codable, Equatable {
    var selectedCategories: Set<String> = []
    var selectedTopics: Set<String> = []
    var categoryMatchMode: NewsFilter.MatchMode = .any
    var topicMatchMode: NewsFilter.MatchMode = .any
}
