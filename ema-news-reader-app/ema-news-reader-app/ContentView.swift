//
//  ContentView.swift
//  ema-news-reader-app
//
//  Created by christina on 17.09.26.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Your EMA overview")
                    .font(.headline)
                
                Text("News, events and guidance will appear here.")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .navigationTitle("Your Briefing")
        }
    }
}

#Preview {
    ContentView()
}
