//
//  NewsCard.swift
//  ema-news-reader
//
//  Created by christina on 26.09.26.
//

import SwiftUI

struct NewsCard: View {
    let title: String
    let category: [String]
    let topics: [String]
    let isNew: Bool
    var isRead: Bool = false
    var isUpdated: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(category.joined(separator: " · "))
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                
                Spacer()
                
                if isRead {
                    Label("Read", systemImage: "checkmark.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if isNew {
                    Text("NEW")
                        .font(.caption.bold())
                        .foregroundStyle(.blue)
                }
            }
            
            if isUpdated {
                Label("UPDATED", systemImage: "arrow.triangle.2.circlepath")
                    .font(.caption.bold())
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Color.blue.opacity(0.12),
                        in: Capsule()
                    )
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


#Preview("Read Article") {
    let newsItem = NewsRecord.samples[1]
    
    NewsCard(
        title: newsItem.title,
        category: newsItem.categoryValues,
        topics: newsItem.topicValues,
        isNew: false,
        isRead: true
    )
    .padding()
    .background(Color.blue.opacity(0.08))
}

#Preview("Previously read, now updated") {
    let article = NewsRecord.samples[0]
    
    NewsCard(
        title: article.title,
        category: article.categoryValues,
        topics: article.topicValues,
        isNew: false,
        isRead: true,
        isUpdated: true
    )
    .padding()
    .background(Color.blue.opacity(0.08))
}
