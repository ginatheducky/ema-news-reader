//
//  ContentView.swift
//  ema-news-reader
//
//  Created by christina on 26.09.26.
//

import SwiftUI

enum AppTab: Hashable {
    case news
    case events
    case briefing
    case guidance
    case media
}

struct ContentView: View {
    @AppStorage("briefing.showNews") private var showNews = true
    
    @State private var selectedTab: AppTab = .briefing
    @State private var isEditingBriefing = false
    @State private var draftShowNews = true
    @State private var newsStore: NewsStore
    
    init(newsStore: NewsStore = NewsStore()) {
        _newsStore = State(initialValue: newsStore)
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("News", systemImage: "newspaper", value: AppTab.news) {
                LiveNewsView(store: newsStore)
            }
            
            Tab("Events", systemImage: "calendar", value: AppTab.events) {
                NavigationStack {
                    Text("Events will appear here.")
                        .navigationTitle("Events")
                }
            }
            
            Tab("Your Briefing", systemImage: "newspaper", value: AppTab.briefing) {
                briefingContent
            }
            
            Tab("Guidance", systemImage: "book", value: AppTab.guidance) {
                NavigationStack {
                    Text("Guidance will appear here.")
                        .navigationTitle("Guidance")
                }
            }
            
            Tab("Media", systemImage: "play.circle", value: AppTab.media) {
                NavigationStack {
                    Text("YouTube videos will be added in a later update.")
                        .navigationTitle("Media")
                }
            }
        }
        .task {
            await newsStore.loadIfNeeded()
        }
    }
    
    private var briefingContent: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your EMA overview")
                        .font(.headline)
                    
                    if let lastRefresh = newsStore.lastSuccessfulRefresh {
                        Text("Last checked: \(lastRefresh.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Your latest EMA news will appear here.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    if showNews {
                        HStack {
                            Text("Latest news")
                                .font(.title2.bold())
                                .accessibilityAddTraits(.isHeader)
                            
                            Spacer()
                            
                            Button {
                                selectedTab = AppTab.news
                            } label: {
                                Label("See all", systemImage: "chevron.right")
                                    .font(.subheadline)
                                    .frame(minHeight: 44)
                                    .contentShape(Rectangle())
                            }
                            .accessibilityLabel("See all news")
                        }
                        
                        if let articles = newsStore.articles {
                            if articles.isEmpty {
                                Text("No news available.")
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(articles.prefix(2), id: \.newsURL) { article in
                                    NavigationLink {
                                        NewsDetailView(article: article)
                                    } label: {
                                        NewsCard(
                                            title: article.title,
                                            category: article.categoryValues,
                                            topics: article.topicValues,
                                            isNew: false
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        } else if newsStore.isLoading {
                            ProgressView("Loading EMA news…")
                        } else {
                            if let error = newsStore.errorMessage {
                                Text(error)
                                    .foregroundStyle(.secondary)
                            }
                            Button(
                                newsStore.errorMessage == nil ? "Load EMA news" : "Try again"
                            ) {
                                Task {
                                    await newsStore.loadNews()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    } else {
                        Text("News is hidden. Tap Edit to show it in your briefing.")
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .background(Color.blue.opacity(0.08))
            .navigationTitle("Your Briefing")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit", systemImage: "slider.horizontal.3") {
                        draftShowNews = showNews
                        isEditingBriefing = true
                    }
                }
            }
            .sheet(isPresented: $isEditingBriefing) {
                BriefingEditor(
                    draftShowNews: $draftShowNews,
                    onCancel: {
                        isEditingBriefing = false
                    },
                    onSave: {
                        showNews = draftShowNews
                        isEditingBriefing = false
                    }
                )
            }
        }
    }
}



#Preview {
    ContentView(newsStore: NewsStore(loadArticles: {
        NewsFeed(data: NewsRecord.samples).newestFirst
    }))
}
