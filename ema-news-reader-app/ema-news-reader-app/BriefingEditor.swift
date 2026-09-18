//
//  BriefingEditor.swift
//  ema-news-reader-app
//
//  Created by christina on 17.09.26.
//

import SwiftUI


struct BriefingEditor: View {
    @Binding var draftShowNews: Bool
    
    // these let the parent supply the actions
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
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                    }
                }
            }
        }
    }
}


private struct BriefingEditorPreview: View {
    @State private var showNews = true
    
    var body: some View {
        BriefingEditor(
            draftShowNews: $showNews,
            onCancel: {},
            onSave: {}
        )
    }
}

#Preview {
    BriefingEditorPreview()
}
