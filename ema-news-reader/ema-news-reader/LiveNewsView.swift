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
                    .safeAreaInset(edge: .bottom) {
                        VStack(spacing: 8) {
                            if let errorMessage = store.errorMessage {
                                Text(errorMessage)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            if store.isLoading {
                                ProgressView("Refreshing news…")
                            } else {
                                Button {
                                    Task {
                                        await store.loadNews()
                                    }
                                } label: {
                                    Label("Refresh news", systemImage: "arrow.clockwise")
                                        .frame(minHeight: 44)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(.regularMaterial)
                    }
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
