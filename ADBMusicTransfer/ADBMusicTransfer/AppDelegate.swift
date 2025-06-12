//
//  AppDelegate.swift
//  ADBMusicTransfer
//
//  Created by 桃源老師 on 2025/06/07.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, ObservableObject {
    
    var workFlag:Bool = false
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 起動時に現在のウインドウにデリゲートを設定
        DispatchQueue.main.async {
            NSApplication.shared.windows.first?.delegate = self
        }
    }
    
    /* 副作用が出たので廃止
     func windowWillClose(_ notification: Notification) {
     // 強制終了中や処理中の場合は terminate を呼ばない
     if !workFlag {
     NSApplication.shared.terminate(nil)
     }
     }
     */
    
    // windowShouldCloseに変更。shouldCloseなので、ウインドウを閉じる時に実行すべき処理が書き込まれる。赤ボタンでウインドウを閉じる時に呼ばれる。
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        return confirmIfWorking {
            // ウインドウを閉じる処理は不要。true を返すことで macOS が閉じてくれる
        }
    }
    
    // ウインドウが閉じたらAppを終了
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    // 関数名の通り、アプリが終了する時に実行すべき処理が書かれる。Cmd + Q / アプリ終了で呼ばれる。
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        
        let result = confirmIfWorking {
            // OKが押された場合はここで NSApp.terminate(nil) しない！
            // return .terminateNow を返せば macOS が終了処理してくれる
        }
        
        return result ? .terminateNow : .terminateCancel
    }
    
    // windowShouldClose/applicationShouldTerminateで共通の確認処理
    func confirmIfWorking(actionAfterConfirm: @escaping () -> Void) -> Bool {
        guard workFlag else {
            return true // 作業していないならそのまま続行
        }
        
        let anAlert = NSAlert()
        anAlert.messageText = NSLocalizedString("Working!!", comment: "Working")
        anAlert.informativeText = NSLocalizedString("I'm working, Are you sure you want to quit now?", comment: "Working Info")
        anAlert.addButton(withTitle: "OK")
        anAlert.addButton(withTitle: NSLocalizedString("Cancel", comment: "Cancel"))
        anAlert.buttons[0].keyEquivalent = "\033"
        anAlert.buttons[1].keyEquivalent = "\r"
        
        let response = anAlert.runModal()
        if response == .alertFirstButtonReturn {
            stopTask()
            actionAfterConfirm()
            return true
        } else {
            return false
        }
    }
    
    func stopTask() {
        
        self.workFlag = false
        
        if process.isRunning {
            
            process.terminate()
        }
        
        // NSApp.terminate(self) ← ここではやらない！
    }
}
