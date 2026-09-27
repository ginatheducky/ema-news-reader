//
//  NewsView.swift
//  ema-news-reader
//
//  Created by christina on 27.09.26.
//

import SwiftUI

struct NewsView: View {
    let articles: [NewsRecord]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(articles, id: \.newsURL) { article in
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
            .navigationTitle("News")
        }
    }
}

#Preview {
    NewsView(
        articles: NewsFeed(data: NewsRecord.samples).newestFirst
    )
}
