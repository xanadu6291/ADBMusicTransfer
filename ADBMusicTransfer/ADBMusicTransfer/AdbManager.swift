//
//  AdbManager.swift
//  ADBMusicTransfer
//
//  Created by 桃源老師 on 2025/06/03.
//

import Foundation
import AppKit
import SwiftUI

var process = Process()

// adb操作に関するクラス
final class AdbManager: ObservableObject {
    
    // adbの準備状況を保持するフラグ
    @Published var isReady: Bool = false
    
    // adbパス変数の定義とユーザーデフォルトへの格納
    @Published var adbPath: String? {
        didSet {
            if let adbPath = adbPath {
                UserDefaults.standard.set(adbPath, forKey: "adbPath")
                
                // adbPathを設定した直後にisReadyを再チェック
                self.isReady = FileManager.default.isExecutableFile(atPath: adbPath)
            } else {
                self.isReady = false
            }
        }
    }
    
    // このクラスのinitメソッド
    init() {
        
        // ユーザーデフォルトに保持されていたadbパスを検証
        if let savedPath = UserDefaults.standard.string(forKey: "adbPath"),
           FileManager.default.isExecutableFile(atPath: savedPath) {
            adbPath = savedPath
        } else {
            
            // 無ければ、detectAdbPath()を呼び出す
            DispatchQueue.main.async {
                self.detectAdbPath { path in
                    if let path = path {
                        self.adbPath = path
                        self.isReady = true
                    } else {
                        self.adbPath = nil
                        self.isReady = false
                    }
                }
            }
        }
    }
    
    // whichを使ってadbパスを取得
    func detectAdbPath(completion: @escaping (String?) -> Void) {
        DispatchQueue.global().async {
            let process = Process()
            let pipe = Pipe()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
            process.arguments = ["adb"]
            process.standardOutput = pipe
            process.standardError = pipe
            // 環境変数（GUIアプリ（Xcodeで起動したりFinderから起動したアプリ）は、システム全体の環境変数 PATHを引き継がずに起動されるので、宣言が必要）
            var env = ProcessInfo.processInfo.environment
            env["PATH"] = "\(NSHomeDirectory())/Library/Android/sdk/platform-tools:/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:"
            process.environment = env
            
            do {
                try process.run()
                process.waitUntilExit()
            } catch {
                DispatchQueue.main.async {
                    self.adbPath = nil
                    self.isReady = false
                    completion(nil)
                }
                return
            }
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let path = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            DispatchQueue.main.async {
                if let path = path, FileManager.default.isExecutableFile(atPath: path) {
                    self.adbPath = path
                    self.isReady = true
                    completion(path)
                } else {
                    self.adbPath = nil
                    self.isReady = false
                    completion(nil)
                }
            }
        }
    }
    
    // adb手動選択機能
    func promptForAdb() {
        let panel = NSOpenPanel()
        panel.message = NSLocalizedString("Choose installed ADB", comment: "")
        panel.prompt = NSLocalizedString("Choose", comment: "")
        if #available(macOS 12.0, *) {
            panel.allowedContentTypes = [] // 全て許可（制限なし）
        } else {
            panel.allowedFileTypes = nil // macOS 11以前のため
        }
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        
        if panel.runModal() == .OK, let selected = panel.url?.path,
           FileManager.default.isExecutableFile(atPath: selected) {
            adbPath = selected
        }
        
        print("ADB Path:", adbPath ?? "nil")
        print("Executable?", FileManager.default.isExecutableFile(atPath: adbPath ?? "") ? "Yes" : "No")
    }
    
    // ADB実行機能（時間がかかった時にバルーンカーソルになるのを防ぐため、非同期で実行）
    func run(arguments: [String], envHome: String? = nil, completion: @escaping (String) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let adbPath = self.adbPath else {
                DispatchQueue.main.async {
                    completion(NSLocalizedString("ADB Path not found", comment: ""))
                    return
                }
                return
            }
            
            let pipe = Pipe()
            process = Process()
            process.executableURL = URL(fileURLWithPath: adbPath)
            process.arguments = arguments
            process.standardOutput = pipe
            process.standardError = pipe
            
            var env = ProcessInfo.processInfo.environment
            if let home = envHome {
                env["HOME"] = home
            }
            process.environment = env
            
            do {
                try process.run()
                process.waitUntilExit()
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? NSLocalizedString("ADB Output not found", comment: "")
                completion(output)
            } catch {
                completion(String(format: NSLocalizedString("adb execution failed: %@", comment: ""), error.localizedDescription))
            }
        }
    }
    
    // ラップ関数（adb devicesを実行）
    func getConnectedDevices(completion: @escaping ([String]) -> Void) {
        run(arguments: ["devices"]) { output in
            let lines = output.components(separatedBy: "\n")
            let devices = lines
                .dropFirst() // 「List of devices attached」除去
                .filter { $0.contains("\tdevice") && !$0.contains("unauthorized") }
                .compactMap { $0.components(separatedBy: "\t").first }
            
            completion(devices)
        }
    }
}
