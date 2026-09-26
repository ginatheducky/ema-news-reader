//
//  BriefingEditor.swift
//  ema-news-reader
//
//  Created by christina on 26.09.26.
//

import SwiftUI

struct BriefingEditor: View {
    @Binding var draftShowNews: Bool
    let onCancel: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Sections") {
                    Toggle("News", isOn: $draftShowNews)
                }
            }
            .navigationTitle("Edit your briefing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Save") {
                        onSave()
                    }
                }
            }
        }
    }
}

private struct BriefingEditorPreview: View {
    @State private var draftShowNews = true
    
    var body: some View {
        BriefingEditor(
            draftShowNews: $draftShowNews,
            onCancel: {},
            onSave: {}
        )
    }
}

#Preview {
    BriefingEditorPreview()
}
