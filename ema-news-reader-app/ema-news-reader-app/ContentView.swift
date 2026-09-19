//
//  ContentView.swift
//  ema-news-reader-app
//
//  Created by christina on 17.09.26.
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
    // @State give SwiftUI ownership of this changing value; it's temporary UI state, so a fresh app launch starts with .briefing again
    @State private var selectedTab: AppTab = .briefing
    
    // @AppStorage connects a property to UserDefaults, Apple's storage for small preferences; brifing.showNews is the persistent storage key; true is the fallback when no preference has been saved
    @AppStorage("briefing.showNews") private var showNews = true
    
    @State private var isEditingBriefing = false
    @State private var draftShowNews = true
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("News", systemImage: "newspaper", value: AppTab.news) {
                NewsView(
                    articles: NewsFeed(data: NewsRecord.samples).newestFirst
                )
            }
            
            Tab("Events", systemImage: "calendar", value: AppTab.events) {
                NavigationStack {
                    Text("Events will appear here.")
                        .navigationTitle("Events")
                }
            }
            
            Tab("Your Briefing", systemImage: "house", value: AppTab.briefing) {
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
                        HStack {
                            Text("Latest news")
                                .font(.title2.bold())
                                .accessibilityAddTraits(.isHeader)
                            
                            Spacer()
                            
                            Button {
                                // select the news tab
                                selectedTab = AppTab.news
                            } label: {
                                Label("See all", systemImage: "chevron.right")
                                    .font(.subheadline)
                                    .frame(minHeight: 44)
                                    .contentShape(Rectangle())
                            }
                            .accessibilityLabel("See all news")
                        }
                        
                        NewsCard(category: "Human", title: "Sample news title for layout testing.", summary: nil, isNew: true)
                        
                        NewsCard(category: "Human", title: "Sample news title for layout testing.", summary: "Sample summary used to check spacing and readability.", isNew: true)
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
                        draftShowNews = showNews // start editing from the users currently saved choice
                        isEditingBriefing = true // opens the sheet
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
    ContentView()
}
