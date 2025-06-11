//
//  Utils.swift
//  ADBMusicTransfer
//
//  Created by 桃源老師 on 2025/06/05.
//

import Foundation

struct MusicLibraryUtil {
    
    // メディアフォルダパス取得機能
    static func resolveMusicLibraryMediaFolder() -> URL? {
        
        // メディアフォルダパスはString型で、Preferencesのcom.apple.Music.plistにlibrary-urlをキーとして格納されている
        let prefsPath = ("~/Library/Preferences/com.apple.Music.plist" as NSString).expandingTildeInPath
        
        guard let plist = NSDictionary(contentsOfFile: prefsPath),
              let urlString = plist["library-url"] as? String,
              let libraryURL = URL(string: urlString) else {
            return nil
        }
        
        // Media.localized/Music フォルダのパスを組み立て
        let mediaFolder = libraryURL
            .deletingLastPathComponent()
            .appendingPathComponent("Media.localized")
            .appendingPathComponent("Music")
        
        return mediaFolder
    }
    
    // 補完用のアーティスト名を読み込む機能
    static func loadArtistNames(from baseURL: URL) -> [String] {
        
        // baseURLの中身を取得
        guard let contents = try? FileManager.default.contentsOfDirectory(at: baseURL, includingPropertiesForKeys: nil) else {
            return []
        }

        // その中身の最後のパス要素（＝アーティスト名）を取得
        return contents.filter { url in
            var isDir: ObjCBool = false
            return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) && isDir.boolValue
        }.map { $0.lastPathComponent }
    }
}
