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
    
    private var filteredArticles: [NewsRecord] {
        articles.filter { article in
            article.matchesSearch(searchText)
        }
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
                    ContentUnavailableView.search(text: searchText)
                }
            }
            .navigationTitle("News")
            .searchable(
                text: $searchText,
                prompt: "Search titles and summaries"
            )
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
