//
//  NewsCard.swift
//  ema-news-reader
//
//  Created by christina on 11.11.26.
//

import SwiftUI
import Foundation

struct NewsCard: View {
    let item: NewsItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                if !item.categories.isEmpty {
                    Text(item.categories.joined(separator: " · "))
                        .font(.subheadline)
                    
                    Text("|")
                        .font(.subheadline)
                }
                
                Text(item.firstPublishedDate, format: Date.FormatStyle(
                    date: .abbreviated,
                    time: .omitted,
                    timeZone: .gmt)
                )
                .font(.subheadline)
            }
            
            Text(item.title)
                .font(.headline)
            
            if !item.topics.isEmpty {
                Text("Topics: \(item.topics.joined(separator: " · "))")
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

#Preview("News card from JSON") {
    switch Result(catching: { try NewsItem.loadPreviewSamples() }) {
    case .success(let items):
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                NewsCard(item: items[0])
            }
            .padding()
        }
        .background(Color.blue.opacity(0.08))
    case .failure(let error):
        Text("Couldn’t load NewsPreview.json: \(error.localizedDescription)")
    }
}
