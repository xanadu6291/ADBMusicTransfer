//
//  ADBMusicTransferApp.swift
//  ADBMusicTransfer
//
//  Created by 桃源老師 on 2025/06/01.
//

import SwiftUI

@main
struct AdbMusicTransferApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var adbManager = AdbManager()
    
    init() {
        // タブ（Tab）に関するメニューを無効化
        NSWindow.allowsAutomaticWindowTabbing = false
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(adbManager)
                .frame(minWidth: 500, idealWidth: 600, maxWidth: 700, minHeight: 520)
                .background(WindowAccessor()) // ウィンドウ取得用の裏技
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button(NSLocalizedString("NewWindow", comment: "")) { }.disabled(true)
            } // ファイルメニューは残し新規ウインドウを無効化（全部消してNew Windowを追加、disabledにするのがトリッキーな裏技）
            CommandGroup(replacing: .undoRedo) { } // 取り消す/やり直すメニューを無効化
            CommandGroup(replacing: .windowArrangement) { } // ウインドウメニューを無効化
            CommandGroup(replacing: .windowSize) { } // 拡大/縮小・しまうメニューを無効化
        }
    }
}
