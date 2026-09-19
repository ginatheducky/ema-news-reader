//
//  NewsView.swift
//  ema-news-reader-app
//
//  Created by christina on 19.09.26.
//

import SwiftUI

struct NewsView: View {
    let articles: [NewsRecord]
    
    @State private var searchText = ""
    @State private var selectedCategories: Set<String> = []
    @State private var categoryMatchMode: CategoryMatchMode = .any
    
    private var availableCategories: [String] {
        NewsFeed(data: articles).availableCategories
    }
    
    private var filteredArticles: [NewsRecord] {
        articles.filter { article in
            article.matchesSearch(searchText) && article.matchesCategories(selectedCategories, mode: categoryMatchMode)
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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(filteredArticles, id: \.newsURL) { article in
                        NavigationLink {
                            NewsDetailView(article: article)
                        } label: {
                            NewsCard(
                                title: article.title,
                                category: article.categoryValues,
                                topics: article.topicValues,
                                isNew: false
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
                        description: Text("Try another search or clear your category selections.")
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
                        
                        Divider()
                        
                        Button("Clear categories") {
                            selectedCategories.removeAll()
                        }
                        .disabled(selectedCategories.isEmpty)
                    } label: {
                        Label(
                            selectedCategories.isEmpty
                                ? "Categories"
                                : "Categories (\(selectedCategories.count))",
                            systemImage: "line.3.horizontal.decrease"
                        )
                    }
                    .menuActionDismissBehavior(.disabled)
                }
            }
        }
    }
}

#Preview {
    NewsView(
        articles: NewsFeed(data: NewsRecord.samples).newestFirst
    )
}

#Preview("Empty news") {
    NewsView(articles: [])
}
