//
//  NewsScreen.swift
//  ema-news-reader
//
//  Created by christina on 12.11.26.
//

import SwiftUI
import Foundation


struct NewsScreen: View {
    let feedURL: URL
    let store: NewsStore
    
    var body: some View {
        if let feed = store.feed {
            NewsListView(items: feed.items)
                .refreshable {
                    await store.refresh(from: feedURL)
                }
                .safeAreaInset(edge: .top, spacing: 0) {
                    if store.lastError != nil {
                        HStack {
                            Text("Couldn't refresh news.")
                            Spacer()
                            Button("Retry") {
                                Task {
                                    await store.refresh(from: feedURL)
                                }
                            }
                        }
                        .padding()
                        .background(.regularMaterial)
                    }
                }
        } else if store.isLoading {
            ProgressView("Loading news...")
        } else if store.lastError != nil {
            ContentUnavailableView {
                Label("Couldn't load news.", systemImage: "newspaper")
            } description: {
                Text("Check your connection and try again.")
            } actions: {
                Button("Retry") {
                    Task {
                        await store.refresh(from: feedURL)
                    }
                }
            }
        } else {
            Text("News has not loaded.")
        }
    }
}

#Preview("News before first load") {
    let client = EMAClient(request: { _ in
        throw URLError(.notConnectedToInternet)
    })
    
    let store = NewsStore(loader: NewsFeedLoader(client: client))
    
    if let url = URL(string: "https://example.com/news") {
        NewsScreen(feedURL: url, store: store)
    }
}

#Preview("News initial error") {
    let client = EMAClient(request: { _ in
        throw URLError(.notConnectedToInternet)
    })
    
    let store = NewsStore(loader: NewsFeedLoader(client: client))
    
    if let url = URL(string: "https://example.com/news") {
        NewsScreen(feedURL: url, store: store)
            .task {
                await store.refresh(from: url)
            }
    }
}

#Preview("News with articles") {
    let fixture = Result(catching: { try NewsItem.loadPreviewData() })
    let client = EMAClient(request: { url in
        guard let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        ) else {
            throw URLError(.badServerResponse)
        }
        
        return (try fixture.get(), response)
    })
    
    let store = NewsStore(loader: NewsFeedLoader(client: client))
    
    if let url = URL(string: "https://example.com/news") {
        NewsScreen(feedURL: url, store: store)
            .task {
                await store.refresh(from: url)
            }
    }
}

#Preview("News refresh failed") {
    let fixture = Result(catching: { try NewsItem.loadPreviewData() })
    
    let client = EMAClient(request: { url in
        if url.path == "/offline" {
            throw URLError(.notConnectedToInternet)
        }
        
        guard let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        ) else {
            throw URLError(.badServerResponse)
        }
        
        return (try fixture.get(), response)
    })
    
    let store = NewsStore(loader: NewsFeedLoader(client: client))
    
    if let initialURL = URL(string: "https://example.com/news"),
       let failingURL = URL(string: "https://example.com/offline") {
        NewsScreen(feedURL: failingURL, store: store)
            .task {
                await store.refresh(from: initialURL)
                await store.refresh(from: failingURL)
            }
    }
}
