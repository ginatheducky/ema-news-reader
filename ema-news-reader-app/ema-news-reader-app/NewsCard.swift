//
//  NewsCard.swift
//  ema-news-reader-app
//
//  Created by christina on 17.09.26.
//

import SwiftUI

struct NewsCard: View {
    let category: String
    let title: String
    let summary: String?
    let isNew: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(category)
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                
                Spacer()
                
                if isNew {
                    Text("NEW")
                        .font(.caption.bold())
                        .foregroundStyle(.blue)
                }
            }
            
            Text(title)
                .font(.headline)
            
            if let summary {
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(.blue)
                .frame(width: 5)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview("News card - sample") {
    NewsCard(category: "Human", title: "Sample news title for layout testing", summary: "Sample summary used to check spacing and readability.", isNew: true)
        .padding()
        .background(Color.blue.opacity(0.08))
}
