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
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("News", systemImage: "newspaper", value: AppTab.news) {
                NavigationStack {
                    Text("News will appear here.")
                        .navigationTitle("News")
                }
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
                    Text("Media will appear here.")
                        .navigationTitle("Media")
                }
            }
        }
    }
    
    private var briefingContent: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your EMA overview")
                        .font(.headline)
                    
                    Text("News, events and guidance will appear here.")
                        .foregroundStyle(.secondary)
                    
                    if showNews {
                        NewsCard(
                            title: "Sample news title for layout testing",
                            summary: "Sample summary used to check spacing and readability.",
                            category: "Human",
                            isNew: true
                        )
                        NewsCard(
                            title: "Sample news title for layout testing",
                            summary: "Sample summary used to check spacing and readability.",
                            category: "Human",
                            isNew: true
                        )
                        NewsCard(
                            title: "Sample news title for layout testing",
                            summary: "Sample summary used to check spacing and readability.",
                            category: "Human",
                            isNew: true
                        )
                    } else {
                        Text("News is hidden, toggle button to show.")
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .topLeading)
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
}



#Preview {
    ContentView()
}
