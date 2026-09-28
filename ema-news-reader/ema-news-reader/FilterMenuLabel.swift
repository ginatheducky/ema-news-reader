//
//  FilterMenuLabel.swift
//  ema-news-reader
//
//  Created by christina on 28.09.26.
//

import SwiftUI

struct FilterMenuLabel: View {
    let title: String
    let systemImage: String
    let selectionCount: Int
    
    var body: some View {
        Image(systemName: systemImage)
            .font(.body)
            .frame(width: 44, height: 44)
            .overlay(alignment: .topTrailing) {
                if selectionCount > 0 {
                    Text(selectionCount, format: .number)
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                        .frame(minWidth: 18, minHeight: 18)
                        .background(.red, in: Capsule())
                        .padding(.top, 5)
                        .padding(.trailing, 3)
                        .allowsHitTesting(false)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(title)
            .accessibilityValue(
                selectionCount == 0
                ? "No filters selected"
                : "\(selectionCount) selected"
            )
    }
}

#Preview {
    HStack {
        FilterMenuLabel(
            title: "Categories",
            systemImage: "line.3.horizontal.decrease",
            selectionCount: 2
        )
        
        FilterMenuLabel(
            title: "Topics",
            systemImage: "tag",
            selectionCount: 0
        )
    }
    .padding()
}
