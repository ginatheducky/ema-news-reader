//
//  NewsDetailView.swift
//  ema-news-reader
//
//  Created by christina on 12.11.26.
//

import SwiftUI

struct NewsDetailView: View {
    let item: NewsItem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if !item.categories.isEmpty {
                    Text(item.categories.joined(separator: " · "))
                        .font(.subheadline)
                }
                
                Text(item.title)
                    .font(.title.bold())
                    .accessibilityAddTraits(.isHeader)
                
                HStack {
                    Text("Published:")
                    
                    Text(item.firstPublishedDate, format: Date.FormatStyle(
                        date: .abbreviated,
                        time: .omitted,
                        timeZone: .gmt)
                    )
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                
                if let rawDate = item.lastUpdatedDate {
                    HStack {
                        Text("Updated:")
                        
                        Text(rawDate, format: Date.FormatStyle(
                            date: .abbreviated,
                            time: .omitted,
                            timeZone: .gmt)
                        )
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                
                if let summary = item.newsSummary {
                    Text(summary)
                        .font(.body)
                }
                
                
                if !item.topics.isEmpty {
                    Text("Topics")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
                    Text(item.topics.joined(separator: " · "))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                if !item.relatedMedicineReferral.isEmpty {
                    Text("Related Medicines and Referrals")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
                    Text(item.relatedMedicineReferral.joined(separator: " · "))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                if item.pressRelease {
                    Text("Press Release available at EMA.")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
                }
                
                Divider()
                
                Link(destination: item.newsURL) {
                    Label("Open original article", systemImage: "arrow.up.right.square")
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}

#Preview {
    switch Result(catching: { try NewsItem.loadPreviewSamples() }) {
    case .success(let items):
        if let item = items.first {
            NewsDetailView(item: item)
        } else {
            Text("The preview fixture contains no usable articles.")
        }
    case .failure(let error):
        Text("Couldn’t load the preview: \(error.localizedDescription)")
    }
}
