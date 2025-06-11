//
//  AppDelegate.swift
//  ADBMusicTransfer
//
//  Created by 桃源老師 on 2025/06/07.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 起動時に現在のウインドウにデリゲートを設定
        DispatchQueue.main.async {
            NSApplication.shared.windows.first?.delegate = self
        }
    }

    func windowWillClose(_ notification: Notification) {
        // ウインドウが閉じられたらアプリを終了
        NSApplication.shared.terminate(nil)
    }
}
