//
//  NewsScreen.swift
//  ema-news-reader
//
//  Created by christina on 12.11.26.
//

import SwiftUI
import Foundation


struct NewsScreen: View {
    @State private var filter = NewsFilter()
    
    let feedURL: URL
    let store: NewsStore
    
    var body: some View {
        if let feed = store.feed {
            let results = filter.results(from: feed.items)
            let availableCategories = NewsFilter.availableCategories(from: feed.items)
            let availableTopics = NewsFilter.availableTopics(from: feed.items)
            
            NavigationStack {
                Group {
                    if results.isEmpty && !feed.items.isEmpty {
                        ContentUnavailableView {
                            Label("No matching news", systemImage: "magnifyingglass")
                        } description: {
                            Text("Try another search or clear your category and topic selections.")
                        }
                    } else {
                        NewsListView(items: results)
                            .refreshable {
                                await store.refresh(from: feedURL)
                            }
                    }
                }
                .safeAreaInset(edge: .top, spacing: 0) {
                    if store.lastError != nil {
                        HStack {
                            Text("Couldn't refresh news.")
                            Spacer()
                            Button("Retry") {
                                Task {
                                    await store.refresh(from: feedURL)
                                }
                            }
                        }
                        .padding()
                        .background(.regularMaterial)
                    }
                }
                .searchable(text: $filter.query, prompt: "Search news")
                .toolbar {
                    // clear all filters button
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Clear all filters") {
                            filter = NewsFilter()
                        }
                    }
                    
                    // categories
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button("Clear categories") {
                                filter.selectedCategories.removeAll()
                            }
                            .disabled(filter.selectedCategories.isEmpty)
                            
                            Divider()
                            
                            Picker("Category matching", selection: $filter.categoryMode) {
                                Text("Match any").tag(NewsFilter.MatchMode.any)
                                Text("Match all").tag(NewsFilter.MatchMode.all)
                            }
                            
                            Divider()
                            
                            ForEach(availableCategories, id: \.self) { category in
                                Button {
                                    if filter.selectedCategories.contains(category) {
                                        filter.selectedCategories.remove(category)
                                    } else {
                                        filter.selectedCategories.insert(category)
                                    }
                                } label: {
                                    let isSelected = filter.selectedCategories.contains(category)
                                    Label(category, systemImage: isSelected ? "checkmark.circle" : "circle")
                                }
                            }
                        } label: {
                            FilterMenuLabel(
                                title: "Categories",
                                systemImage: "line.3.horizontal.decrease",
                                selectionCount: filter.selectedCategories.count
                            )
                        }
                        .menuActionDismissBehavior(.disabled)
                    }
                    
                    // topics
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button("Clear topics") {
                                filter.selectedTopics.removeAll()
                            }
                            .disabled(filter.selectedTopics.isEmpty)
                            
                            Divider()
                            
                            Picker("Topic matching", selection: $filter.topicMode) {
                                Text("Match any").tag(NewsFilter.MatchMode.any)
                                Text("Match all").tag(NewsFilter.MatchMode.all)
                            }
                            
                            Divider()
                            
                            ForEach(availableTopics, id: \.self) { topic in
                                Button {
                                    if filter.selectedTopics.contains(topic) {
                                        filter.selectedTopics.remove(topic)
                                    } else {
                                        filter.selectedTopics.insert(topic)
                                    }
                                } label: {
                                    let isSelected = filter.selectedTopics.contains(topic)
                                    Label(topic, systemImage: isSelected ? "checkmark.circle" : "circle")
                                }
                            }
                        } label: {
                            FilterMenuLabel(
                                title: "Topics",
                                systemImage: "tag",
                                selectionCount: filter.selectedTopics.count
                            )
                        }
                        .menuActionDismissBehavior(.disabled)
                    }
                }
            }
        } else if store.isLoading {
            ProgressView("Loading news...")
        } else if store.lastError != nil {
            ContentUnavailableView {
                Label("Couldn't load news.", systemImage: "newspaper")
            } description: {
                Text("Check your connection and try again.")
            } actions: {
                Button("Retry") {
                    Task {
                        await store.refresh(from: feedURL)
                    }
                }
            }
        } else {
            Text("News has not loaded.")
        }
    }
}

#Preview("News before first load") {
    let client = EMAClient(request: { _ in
        throw URLError(.notConnectedToInternet)
    })
    
    let store = NewsStore(loader: NewsFeedLoader(client: client))
    
    if let url = URL(string: "https://example.com/news") {
        NewsScreen(feedURL: url, store: store)
    }
}

#Preview("News initial error") {
    let client = EMAClient(request: { _ in
        throw URLError(.notConnectedToInternet)
    })
    
    let store = NewsStore(loader: NewsFeedLoader(client: client))
    
    if let url = URL(string: "https://example.com/news") {
        NewsScreen(feedURL: url, store: store)
            .task {
                await store.refresh(from: url)
            }
    }
}

#Preview("News with articles") {
    let fixture = Result(catching: { try NewsItem.loadPreviewData() })
    let client = EMAClient(request: { url in
        guard let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        ) else {
            throw URLError(.badServerResponse)
        }
        
        return (try fixture.get(), response)
    })
    
    let store = NewsStore(loader: NewsFeedLoader(client: client))
    
    if let url = URL(string: "https://example.com/news") {
        NewsScreen(feedURL: url, store: store)
            .task {
                await store.refresh(from: url)
            }
    }
}

#Preview("News refresh failed") {
    let fixture = Result(catching: { try NewsItem.loadPreviewData() })
    
    let client = EMAClient(request: { url in
        if url.path == "/offline" {
            throw URLError(.notConnectedToInternet)
        }
        
        guard let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        ) else {
            throw URLError(.badServerResponse)
        }
        
        return (try fixture.get(), response)
    })
    
    let store = NewsStore(loader: NewsFeedLoader(client: client))
    
    if let initialURL = URL(string: "https://example.com/news"),
       let failingURL = URL(string: "https://example.com/offline") {
        NewsScreen(feedURL: failingURL, store: store)
            .task {
                await store.refresh(from: initialURL)
                await store.refresh(from: failingURL)
            }
    }
}
