//
//  NewsView.swift
//  ema-news-reader-app
//
//  Created by christina on 19.09.26.
//

import SwiftUI

struct NewsView: View {
    let articles: [NewsRecord]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(articles, id: \.newsURL) { article in
                        NewsCard(
                            category: article.categoryValues.joined(separator: " · "),
                            title: article.title,
                            summary: article.displaySummary,
                            isNew: false
                        )
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
