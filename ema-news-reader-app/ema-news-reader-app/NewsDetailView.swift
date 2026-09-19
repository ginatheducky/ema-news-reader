//
//  NewsDetailView.swift
//  ema-news-reader-app
//
//  Created by christina on 19.09.26.
//

import SwiftUI

struct NewsDetailView: View {
    let article: NewsRecord
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if !article.categoryValues.isEmpty {
                    Text(article.categoryValues.joined(separator: " · "))
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                }
                
                Text(article.title)
                    .font(.title.bold())
                    .accessibilityAddTraits(.isHeader)
                
                if article.publicationDate != nil {
                    Text("Published: \(article.firstPublishedDate)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                if let summary = article.displaySummary {
                    Text(summary)
                        .font(.body)
                }
                
                if !article.topicValues.isEmpty {
                    Text("Topics")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
                    Text(article.topicValues.joined(separator: " · "))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                
                if let url = article.articleURL {
                    Link(destination: url) {
                        Label("Open original article", systemImage: "arrow.up.right.square")
                            .frame(minHeight: 44)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Text("The original article link is unavailable.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.blue.opacity(0.08))
        .navigationTitle("Article")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        NewsDetailView(
            article: NewsRecord.samples[1]
        )
    }
}
