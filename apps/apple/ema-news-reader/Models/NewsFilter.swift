//
//  NewsFilter.swift
//  ema-news-reader
//
//  Created by christina on 12.11.26.
//



struct NewsFilter {
    enum MatchMode {
        case any
        case all
    }
    
    var query = ""
    var selectedCategories: Set<String> = []
    var selectedTopics: Set<String> = []
    var categoryMode: MatchMode = .any
    var topicMode: MatchMode = .any
    
    static func availableCategories(from items: [NewsItem]) -> [String] {
        let values = items.flatMap { item in
            item.categories
        }
        return Set(values).sorted()
    }
    
    static func availableTopics(from items: [NewsItem]) -> [String] {
        let values = items.flatMap { item in
            item.topics
        }
        return Set(values).sorted()
    }
    
    func matches(_ item: NewsItem) -> Bool {
        let searchMatches = item.matchesSearch(query)
        
        let categoryMatches: Bool
        switch categoryMode {
        case .any:
            categoryMatches = item.matchesAnyCategory(selectedCategories)
        case .all:
            categoryMatches = item.matchesAllCategories(selectedCategories)
        }
        
        let topicMatches: Bool
        switch topicMode {
        case .any:
            topicMatches = item.matchesAnyTopic(selectedTopics)
        case .all:
            topicMatches = item.matchesAllTopics(selectedTopics)
        }
        
        return searchMatches && categoryMatches && topicMatches
    }
    
    func results(from items: [NewsItem]) -> [NewsItem] {
        var filteredItems: [NewsItem] = []
        
        for item in items {
            if matches(item) {
                filteredItems.append(item)
            }
        }
        
        return filteredItems.sorted(by: { first, second in
            first.firstPublishedDate > second.firstPublishedDate
        })
    }
}
