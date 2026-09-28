//
//  LiveNewsView.swift
//  ema-news-reader
//
//  Created by christina on 28.09.26.
//

import SwiftUI

struct LiveNewsView: View {
    let store: NewsStore
    
    var body: some View {
        Group {
            if let articles = store.articles {
                NewsView(articles: articles)
            } else {
                NavigationStack {
                    VStack(spacing: 16) {
                        if store.isLoading {
                            ProgressView("Loading EMA news…")
                        } else {
                            if let errorMessage = store.errorMessage {
                                Text(errorMessage)
                                    .multilineTextAlignment(.center)
                            } else {
                                Text("Load the latest news published by EMA.")
                                    .multilineTextAlignment(.center)
                            }
                            
                            Button(
                                store.errorMessage == nil ? "Load EMA news" : "Try again"
                            ) {
                                Task {
                                    await store.loadNews()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.blue.opacity(0.08))
                    .navigationTitle("News")
                }
            }
        }
    }
}


#Preview("Offline loading example") {
    LiveNewsView(store: NewsStore(loadArticles: {
        NewsFeed(data: NewsRecord.samples).newestFirst
    }))
}

#Preview("Failed loading") {
    LiveNewsView(store: NewsStore(loadArticles: {
        throw NewsServiceError.unsuccessfulStatus(503)
    }))
}
