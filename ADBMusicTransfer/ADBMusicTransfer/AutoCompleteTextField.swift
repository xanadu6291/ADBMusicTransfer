//
//  AutoCompleteTextField.swift
//  ADBMusicTransfer
//
//  Created by 桃源老師 on 2025/06/05.
//

import SwiftUI

// テキストフィールドを親ビューとしてサジェスチョンをリスト（子ビュー）で表示させる
struct AutoCompleteTextField: View {
    let label: String
    @Binding var text: String
    let suggestions: [String]
    @Binding var showSuggestions: Bool
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField(label, text: $text)
                .onReceive(NotificationCenter.default.publisher(for: NSTextView.didChangeTypingAttributesNotification)) { _ in
                    showSuggestions = true
                }
                .onSubmit {
                    showSuggestions = false
                    onSubmit()
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            let filteredSuggestions = suggestions.filter {
                       $0.localizedCaseInsensitiveContains(text) && !$0.isEmpty
                   }

            if showSuggestions && filteredSuggestions.count > 1 {
                List {
                    ForEach(filteredSuggestions, id: \.self) { suggestion in
                        Text(suggestion)
                            .onTapGesture {
                                text = suggestion
                                showSuggestions = false
                                onSubmit()
                            }
                    }
                }
                .background(Color(NSColor.controlBackgroundColor))
                .frame(height: 100)
            }
        }
    }
}
