//
//  NewsView.swift
//  ema-news-reader
//
//  Created by christina on 27.09.26.
//

import SwiftUI

struct NewsView: View {
    let articles: [NewsRecord]
    let readArticleURLs: Set<String>
    let newArticleURLs: Set<String>
    let onReadArticle: (NewsRecord) -> Void
    
    private let preferences: UserDefaults?
    
    @State private var searchText = ""
    @State private var selectedCategories: Set<String> = []
    @State private var selectedTopics: Set<String> = []
    @State private var categoryMatchMode: CategoryMatchMode = .any
    @State private var topicMatchMode: TopicMatchMode = .any
    
    
    init(
        articles: [NewsRecord],
        readArticleURLs: Set<String> = [],
        newArticleURLs: Set<String> = [],
        onReadArticle: @escaping (NewsRecord) -> Void = { _ in },
        preferences: UserDefaults? = .standard
    ) {
        self.articles = articles
        self.readArticleURLs = readArticleURLs
        self.onReadArticle = onReadArticle
        self.preferences = preferences
        self.newArticleURLs = newArticleURLs
        
        let categories = preferences?
            .stringArray(forKey: "news.selectedCategories") ?? []
        
        let topics = preferences?
            .stringArray(forKey: "news.selectedTopics") ?? []
        
        let newsModeValue = preferences?
            .string(forKey: "news.categoryMatchMode") ?? "any"
        
        let topicModeValue = preferences?
            .string(forKey: "news.topicMatchMode") ?? "any"
        
        _selectedCategories = State(initialValue: Set(categories))
        _selectedTopics = State(initialValue: Set(topics))
        _categoryMatchMode = State(
            initialValue: CategoryMatchMode(rawValue: newsModeValue) ?? .any
        )
        _topicMatchMode = State(
            initialValue: TopicMatchMode(rawValue: topicModeValue) ?? .any
        )
    }
    
    private var availableCategories: [String] {
        NewsFeed(data: articles).availableCategories
    }
    
    private var availableTopics: [String] {
        NewsFeed(data: articles).availableTopics
    }
    
    private var filteredArticles: [NewsRecord] {
        articles.filter { article in
            article.matchesFilters(
                query: searchText,
                categories: selectedCategories,
                categoryMode: categoryMatchMode,
                topics: selectedTopics,
                topicMode: topicMatchMode
            )
        }
    }
    
    private var newFilteredArticles: [NewsRecord] {
        filteredArticles.filter { article in
            newArticleURLs.contains(article.newsURL)
        }
    }
    
    private func categoryBinding(for category: String) -> Binding<Bool> {
        Binding(
            get: {
                selectedCategories.contains(category)
            },
            set: { isSelected in
                if isSelected {
                    selectedCategories.insert(category)
                } else {
                    selectedCategories.remove(category)
                }
            }
        )
    }
    
    private func topicBinding(for topic: String) -> Binding<Bool> {
        Binding(
            get: {
                selectedTopics.contains(topic)
            },
            set: { isSelected in
                if isSelected {
                    selectedTopics.insert(topic)
                } else {
                    selectedTopics.remove(topic)
                }
            }
        )
    }
    
    private func saveFilters() {
        guard let preferences else {
            return
        }
        
        preferences.set(
            selectedCategories.sorted(),
            forKey: "news.selectedCategories"
        )
        
        preferences.set(
            selectedTopics.sorted(),
            forKey: "news.selectedTopics"
        )
        
        preferences.set(
            categoryMatchMode.rawValue,
            forKey: "news.categoryMatchMode"
        )
        
        preferences.set(
            topicMatchMode.rawValue,
            forKey: "news.topicMatchMode"
        )
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    let newCount = newFilteredArticles.count
                    if newCount > 0 {
                        Text("\(newCount) new \(newCount == 1 ? "article" : "articles") in these results.")
                    }
                    
                    ForEach(filteredArticles, id: \.newsURL) { article in
                        NavigationLink {
                            NewsDetailView(article: article)
                                .onAppear {
                                    onReadArticle(article)
                                }
                        } label: {
                            NewsCard(
                                title: article.title,
                                category: article.categoryValues,
                                topics: article.topicValues,
                                isNew: newArticleURLs.contains(article.newsURL),
                                isRead: readArticleURLs.contains(article.newsURL)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .background(Color.blue.opacity(0.08))
            .overlay {
                if articles.isEmpty {
                    ContentUnavailableView(
                        "No news available",
                        systemImage: "newspaper",
                        description: Text("There are no articles to display.")
                    )
                } else if filteredArticles.isEmpty {
                    ContentUnavailableView(
                        "No matching news",
                        systemImage: "magnifyingglass",
                        description: Text("Try another search or clear your category and topic selections.")
                    )
                }
            }
            .navigationTitle("News")
            .searchable(
                text: $searchText,
                prompt: "Search titles and summaries"
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Clear categories") {
                            selectedCategories.removeAll()
                        }
                        .disabled(selectedCategories.isEmpty)
                        
                        Divider()
                        
                        Picker("Category matching", selection: $categoryMatchMode) {
                            Text("Match any selected").tag(CategoryMatchMode.any)
                            Text("Match all selected").tag(CategoryMatchMode.all)
                        }
                        
                        Divider()
                        
                        ForEach(availableCategories, id: \.self) { category in
                            Toggle(
                                category,
                                isOn: categoryBinding(for: category)
                            )
                        }
                    } label: {
                        FilterMenuLabel(
                            title: "Categories",
                            systemImage: "line.3.horizontal.decrease",
                            selectionCount: selectedCategories.count
                        )
                    }
                    .menuActionDismissBehavior(.disabled)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Clear topics") {
                            selectedTopics.removeAll()
                        }
                        .disabled(selectedTopics.isEmpty)
                        
                        Divider()
                        
                        Picker("Topic matching", selection: $topicMatchMode) {
                            Text("Match any selected").tag(TopicMatchMode.any)
                            Text("Match all selected").tag(TopicMatchMode.all)
                        }
                        
                        Divider()
                        
                        ForEach(availableTopics, id: \.self) { topic in
                            Toggle(
                                topic,
                                isOn: topicBinding(for: topic)
                            )
                        }
                    } label: {
                        FilterMenuLabel(
                            title: "Topics",
                            systemImage: "tag",
                            selectionCount: selectedTopics.count
                        )
                    }
                    .menuActionDismissBehavior(.disabled)
                }
            }
        }
        .onChange(of: selectedCategories) {
            saveFilters()
        }
        .onChange(of: selectedTopics) {
            saveFilters()
        }
        .onChange(of: categoryMatchMode) {
            saveFilters()
        }
        .onChange(of: topicMatchMode) {
            saveFilters()
        }
    }
}

#Preview {
    NewsView(
        articles: NewsFeed(data: NewsRecord.samples).newestFirst,
        preferences: nil
    )
}

#Preview("Empty news") {
    NewsView(articles: [], preferences: nil)
}
