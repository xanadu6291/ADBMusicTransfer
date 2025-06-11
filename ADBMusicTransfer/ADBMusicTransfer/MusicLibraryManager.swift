//
//  MusicLibraryManager.swift
//  ADBMusicTransfer
//
//  Created by 桃源老師 on 2025/06/05.
//

import Foundation

final class MusicLibraryManager {
    
    // 補完用のアルバム名を取得する機能
    static func loadAlbumNames(for artistFolder: URL) -> [String] {
        do {
            
            // アルバム名を含むパス要素を取得
            let contents = try FileManager.default.contentsOfDirectory(
                at: artistFolder,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )
            
            // その要素の最後のパス要素（＝アルバム名）を取得
            let albumDirs = contents.filter { $0.hasDirectoryPath }
            return albumDirs.map { $0.lastPathComponent }
        } catch {
            print("Error loading albums: \(error)")
            return []
        }
    }
}
