//
//  LiveNewsView.swift
//  ema-news-reader
//
//  Created by christina on 28.09.26.
//

import SwiftUI

struct LiveNewsView: View {
    let loadArticles: () async throws -> [NewsRecord]
    
    @State private var articles: [NewsRecord]?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    init(
        loadArticles: @escaping () async throws -> [NewsRecord] = {
            try await NewsService().fetchArticles()
        }
    ) {
        self.loadArticles = loadArticles
    }
    
    
    var body: some View {
        Group {
            if let articles {
                NewsView(articles: articles)
            } else {
                NavigationStack {
                    VStack(spacing: 16) {
                        if isLoading {
                            ProgressView("Loading EMA news…")
                        } else {
                            if let errorMessage {
                                Text(errorMessage)
                                    .multilineTextAlignment(.center)
                            } else {
                                Text("Load the latest news published by EMA.")
                                    .multilineTextAlignment(.center)
                            }
                            
                            Button(
                                errorMessage == nil ? "Load EMA news" : "Try again"
                            ) {
                                Task {
                                    await loadNews()
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
    
    
    private func loadNews() async {
        guard !isLoading else {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        do {
            articles = try await loadArticles()
        } catch is CancellationError {
            // Cancellation is not a failed download to report.
        } catch {
            errorMessage = "News couldn’t be loaded. Please try again."
            print("News load failed:", error)
        }
    }
}


#Preview {
    LiveNewsView()
}

#Preview("Offline loading example") {
    LiveNewsView(loadArticles: {
        NewsFeed(data: NewsRecord.samples).newestFirst
    })
}
