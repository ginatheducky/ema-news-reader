//
//  NewsListView.swift
//  ema-news-reader
//
//  Created by christina on 12.11.26.
//

import SwiftUI

struct NewsListView: View {
    let items: [NewsItem]
    
    var body: some View {
            Group {
                if items.isEmpty {
                    // empty state view
                    ContentUnavailableView(
                        "No news articles",
                        systemImage: "newspaper",
                        description: Text("The EMA news feed is currently empty.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(items, id: \.newsURL) { item in
                                NavigationLink {
                                    NewsDetailView(item: item)
                                } label: {
                                    NewsCard(item: item)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .background {
                Color("AppBackground").ignoresSafeArea()
            }
    }
}

#Preview("News list from JSON") {
    switch Result(catching: { try NewsItem.loadPreviewSamples() }) {
    case .success(let items):
        NewsListView(items: items)
    case .failure(let error):
        Text("Couldn’t load NewsPreview.json: \(error.localizedDescription)")
    }
}

#Preview("Empty news list") {
    NewsListView(items: [])
}
