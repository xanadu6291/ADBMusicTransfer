//
//  WindowAccessor.swift
//  ADBMusicTransfer
//
//  Created by 桃源老師 on 2025/06/06.
//

import SwiftUI

// ウインドウの初期サイズを設定する
struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first {
                window.setContentSize(NSSize(width: 600, height: 535)) // 初期サイズここで設定！
            }
        }
        return NSView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
