//
//  NewsCard.swift
//  ema-news-reader-app
//
//  Created by christina on 17.09.26.
//

import SwiftUI

struct NewsCard: View {
    let title: String
    let category: [String]
    let topics: [String]
    let isNew: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(category.joined(separator: " · "))
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                
                Spacer()
                
                if isNew {
                    Text("NEW")
                        .font(.caption.bold())
                        .foregroundStyle(.blue)
                }
            }
            
            Text(title)
                .font(.headline)
            
            if !topics.isEmpty {
                Text("Topics: \(topics.joined(separator: " · "))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(.blue)
                .frame(width: 5)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview("News card - sample") {
    let newsItem = NewsRecord.samples[1]
    
    NewsCard(
        title: newsItem.title,
        category: newsItem.categoryValues,
        topics: newsItem.topicValues,
        isNew: false
    )
        .padding()
        .background(Color.blue.opacity(0.08))
}
