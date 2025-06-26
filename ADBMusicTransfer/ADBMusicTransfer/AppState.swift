//
//  AppState.swift
//  ADBMusicTransfer
//
//  Created by 桃源老師 on 2025/06/25.
//

import Foundation
import Combine
import SwiftUI

class AppState: ObservableObject {
    var adbManager = AdbManager()
    @Published var adbPath: String = "/usr/local/bin/adb" // 初期値（変更可）
    // @Published var connectedDevice: String = "未接続"
    @Published var libraryArtists: [String] = []
    
    var outputBinding: Binding<String>?
    
    func appendLog(_ message: String) {
        DispatchQueue.main.async {
            if let binding = self.outputBinding {
                binding.wrappedValue += message + "\n"
            } else {
                print(NSLocalizedString("⚠️ outputBinding is not set", comment: ""))
            }
        }
    }
    
    // Music ライブラリを再読み込みする
    func reloadLibrary() {
        appendLog(NSLocalizedString("🔁 Reload Library", comment: ""))
        
        guard let mediaFolderURL = MusicLibraryUtil.resolveMusicLibraryMediaFolder() else {
            appendLog(NSLocalizedString("⚠️ Music Library path not found", comment: ""))
            return
        }
        
        let artists = MusicLibraryUtil.loadArtistNames(from: mediaFolderURL)
        DispatchQueue.main.async {
            self.libraryArtists = artists
            self.appendLog(String(format: NSLocalizedString("Artist count:", comment: ""), String(artists.count)))
        }
    }
    
    // ADB を再検出または手動選択する
    func rescanADB() {
        appendLog(NSLocalizedString("🔍 Rescan ADB…", comment: ""))
        
        adbManager.detectAdbPath { path in
            if let path = path {
                self.appendLog(String(format: NSLocalizedString("ADB found at:", comment: ""),path))
            } else {
                self.appendLog(NSLocalizedString("⚠️ ADB not found", comment: ""))
            }
        }
    }
    
    // adb devices で接続されたデバイス名を確認
    func checkDeviceConnection() {
        adbManager.getConnectedDevices { devices in
            if devices.isEmpty {
                self.appendLog(NSLocalizedString("📡 No device connected", comment: ""))
            } else {
                self.appendLog(String(format: NSLocalizedString("Connected devices:", comment: ""), devices.joined(separator: ", ")))
            }
        }
    }
}
