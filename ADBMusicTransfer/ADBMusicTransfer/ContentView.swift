//
//  ContentView.swift
//  ADBMusicTransfer
//
//  Created by 桃源老師 on 2025/06/01.
//

import SwiftUI
import Foundation
import AppKit

struct ContentView: View {
    @EnvironmentObject var adbManager: AdbManager
    @State private var artist: String = ""
    @State private var allArtists: [String] = []
    @State private var artistSuggestions: [String] = []
    @State private var showArtistSuggestions: Bool = false
    @State private var album = ""
    @State private var allAlbums: [String] = []
    @State private var albumSuggestions: [String] = []
    @State private var showAlbumSuggestions: Bool = false
    @State var isNewArtist = false
    @State private var output: String = ""
    @State private var selectedStorageType: StorageType = .sdCard
    
    var body: some View {
        
        ScrollView {
            
            VStack(alignment: .leading, spacing: 16) {
                
                // Text("isReady: \(adbManager.isReady.description)")
                
                HStack {
                    
                    /*
                     Text(
                     String(
                     format: NSLocalizedString("ADBPathLabel", comment: ""),
                     adbManager.adbPath ?? NSLocalizedString("Unknown", comment: "")
                     )
                     ).font(.caption)
                     */
                    
                    // ADBパスを手動選択するボタン
                    Button("Button.Select ADB manually") {
                        adbManager.promptForAdb()
                    }
                    
                    // ADB Devicesコマンドを実行するボタン
                    Button("Button.Confirm ADB Devices") {
                        adbManager.run(arguments: ["devices"]) { result in
                            DispatchQueue.main.async {
                                output += result
                            }
                        }
                    }
                }
                
                // ピッカーで音楽ファイルを転送するストレージタイプを選択する
                Picker("Picker.StorageType", selection: $selectedStorageType) {
                    ForEach(StorageType.allCases) { type in
                        Text(type.localizedDescription).tag(type)
                    }
                }
                
                // アーティスト名を補完するビュー（テキストフィールド）の呼び出し
                AutoCompleteTextField(
                    label: NSLocalizedString("TextField.Artist", comment: ""),
                    text: $artist,
                    suggestions: artistSuggestions,
                    showSuggestions: $showArtistSuggestions
                ) {
                    
                }
                // ビューが準備できたら、すべてのアーティスト名を読み込む
                .onAppear {
                    if let musicPath = MusicLibraryUtil.resolveMusicLibraryMediaFolder() {
                        allArtists = MusicLibraryUtil.loadArtistNames(from: musicPath)
                        // print("All Artists: \(allArtists)")
                    }
                }
                .onChange(of: artist) {
                    showArtistSuggestions = !artist.isEmpty
                    artistSuggestions = allArtists.filter { $0.lowercased().contains(artist.lowercased()) }
                    
                    // アルバム補完用の一覧を読み込む
                    if let mediaPath = MusicLibraryUtil.resolveMusicLibraryMediaFolder() {
                        let artistFolder = mediaPath.appendingPathComponent(artist)
                        allAlbums = MusicLibraryManager.loadAlbumNames(for: artistFolder)
                        albumSuggestions = allAlbums                      // ← 追加
                        showAlbumSuggestions = !albumSuggestions.isEmpty  // ← 修正
                        // print("Show Album Suggestions: \(showAlbumSuggestions)")
                        // print("Album Suggestions: \(albumSuggestions)")
                        // print("Albums for \(artist): \(allAlbums)")
                    }
                }
                
                // 新規アーティストかどうかを設定するトグル（チェックボックス）
                Toggle(isOn: $isNewArtist) {
                    Text("Toggle.NewArtist")
                }
                .padding(.horizontal)
                
                // アルバム名を補完するビュー（テキストフィールド）の呼び出し
                AutoCompleteTextField(
                    label: NSLocalizedString("TextField.Album", comment: ""),
                    text: $album,
                    suggestions: albumSuggestions,
                    showSuggestions: .constant(!isNewArtist && showAlbumSuggestions && !album.isEmpty), // ←ここで調整！
                ) {
                    showAlbumSuggestions = false
                }.disabled(isNewArtist) // ← チェックが入っていたら無効化
                
                // 転送ボタン
                Button("Button.TransferMusic") {
                    print(selectedStorageType.path)
                    transferMusic()
                }
                .padding()
                .disabled(!adbManager.isReady || artist.trimmingCharacters(in: .whitespaces).isEmpty || (album.trimmingCharacters(in: .whitespaces).isEmpty && !isNewArtist)) // adbが未準備またはアーティスト名が空欄、またはアルバム名が空欄（新規アーティストを除く）のときは、ボタンをイネーブルしない
                
                // ログ出力用（ログをコピペ可能にする）
                Section(header: Text("Text.Log")) {
                    
                    // スクロール可能にするため、ScrollViewを用いる
                    ScrollView {
                        Text(output)
                            .font(.system(.body, design: .monospaced))
                            .textSelection(.enabled) // ← ★ ここでコピペ可能に
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(4)
                    }
                    .frame(height: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.4))
                    )
                }
                .frame(maxHeight: 300)
            }
            .padding()
            
            // アプリ起動時にadbManager.adbPathをチェックし、それをログ(output)に反映
            .onReceive(adbManager.$adbPath) { path in
                let resolved = path ?? NSLocalizedString("Unknown", comment: "")
                output += String(format: NSLocalizedString("ADBPathLabel", comment: ""), resolved) + "\n"
            }
        }.frame(height: 520) // 高さ固定で、リフローを防ぐ
    }
    
    
    // 転送機能
    func transferMusic() {
        output = "" // 機能の呼び出しごとにログをクリア
        
        /* 同梱はライセンス上問題があるので取り止め
         // 同梱adbパス取得
         guard let adbPath = Bundle.main.path(forResource: "adb", ofType: nil) else {
         output = NSLocalizedString("adb does not exist", comment: "")
         return
         }
         */
        
        // 現在のユーザーのホームディレクトリパス取得
        let envHome = FileManager.default.homeDirectoryForCurrentUser.path
        
        // ADBパス自動取得
        guard let adbPath = adbManager.adbPath else {
            output += NSLocalizedString("ADB path is not set", comment: "")
            return
        }
        
        // Mediaフォルダパス取得（フォルダに含まれるローカライズ名は、ハードコードすべきでない）
        // let basePath = envHome + NSLocalizedString("/Music/Music/Media.localized/Music/", comment: "")
        /*
         var basePath:String = ""
         if let mediaFolder = resolveMusicLibraryMediaFolder() {
         basePath = mediaFolder.path + "/"
         }
         */
        
        // ソースパス設定時に強制アンラップを避ける
        guard let baseURL = MusicLibraryUtil.resolveMusicLibraryMediaFolder() else {
            output += NSLocalizedString("Base music path is invalid.", comment: "")
            return
        }
        
        let sourceURL: URL
        var targetBasePath: String = ""
        let targetPath: String
        
        // ターゲット（保存先）がSDカードか内部ストレージかによる分岐
        if selectedStorageType == .sdCard {
            
            // 転送先SDカードのUUID取得
            guard let sdUUID = detectSDUUID(adbPath: adbPath, home: envHome) else {
                output += NSLocalizedString("Can't obtain SD card UUID", comment: "")
                return
            }
            
            targetBasePath = "/storage/\(sdUUID)/Music"
            
        } else if selectedStorageType == .internalStorage {
            
            targetBasePath = selectedStorageType.path
        }
        
        // ソース、ターゲット、それぞれのパス設定。新規アーティストかどうかで切り分ける。
        if isNewArtist {
            sourceURL = baseURL.appendingPathComponent(artist)
            targetPath = targetBasePath
        } else {
            sourceURL = baseURL.appendingPathComponent(artist).appendingPathComponent(album)
            targetPath = targetBasePath + "/" + artist
        }
        
        let sourcePath = sourceURL.path
        
        // ソースパスの存在確認
        guard FileManager.default.fileExists(atPath: sourcePath) else {
            output += String(format: NSLocalizedString("Can't find music file：", comment: ""), sourcePath)
            return
        }
        
        // 改行と空白の除去
        let trimmedSource = sourcePath.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTarget = targetPath.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // ログ出力の整形
        output += NSLocalizedString("StartTransfer", comment: "") + "\n\n"
        // output += NSLocalizedString("ADB OUTPUT:\n", comment: "")
        output += String(format: NSLocalizedString("Souce:", comment: ""), trimmedSource + "\n")
        output += String(format: NSLocalizedString("Target:", comment: ""), trimmedTarget + "\n\n")
        
        // ADB実行機能呼び出し
        adbManager.run(arguments: ["push", sourcePath, targetPath], envHome: envHome) { result in
            
            // ここで result を受け取り処理
            DispatchQueue.main.async {
                output += result
                
                let resultMessage = result.contains("error")
                ? NSLocalizedString("TransferFailed", comment: "Transfer failed with warning icon")
                : NSLocalizedString("TransferSucceeded", comment: "Transfer succeeded with checkmark icon")
                
                output += "\n\(resultMessage)\n"
            }
        }
    }
    
    // 転送先SDカードのUUID取得機能
    func detectSDUUID(adbPath: String, home: String) -> String? {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: adbPath)
        process.arguments = ["shell", "sm", "list-volumes", "public"]
        process.standardOutput = pipe
        
        var env = ProcessInfo.processInfo.environment
        env["HOME"] = home
        process.environment = env
        
        do {
            try process.run()
        } catch {
            output += String(format: NSLocalizedString("adb start failed:", comment: ""), error.localizedDescription) + "\n"
            return nil
        }
        
        process.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let outputString = String(data: data, encoding: .utf8) else {
            output += NSLocalizedString("Can't convert ADB output to string\n", comment: "")
            return nil
        }
        
        output += String(format: NSLocalizedString("ADB Output:", comment: ""), outputString) + "\n"
        
        // 正規表現で UUID を抽出
        let lines = outputString.split(separator: "\\n")
        for line in lines {
            let parts = line.split(separator: " ")
            if parts.count >= 3 && parts[1] == "mounted" {
                
                // ここが UUID。取得結果は改行を含むので除去する
                return String(parts[2]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        return nil
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // ContentView()
    }
}
