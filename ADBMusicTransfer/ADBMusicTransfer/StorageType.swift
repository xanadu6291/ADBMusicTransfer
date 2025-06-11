//
//  StorageType.swift
//  ADBMusicTransfer
//
//  Created by 桃源老師 on 2025/06/04.
//

import Foundation

// 内部ストレージかSDカードかを選択するenum
enum StorageType: String, CaseIterable, Identifiable {
    case internalStorage
    case sdCard
    
    var id: String { self.rawValue }
    
    var path: String {
        switch self {
        case .internalStorage:
            return "/storage/emulated/0/Music"
        case .sdCard:
            return ""
        }
    }
    
    var localizedDescription: String {
        switch self {
        case .internalStorage:
            return NSLocalizedString("InternalStorage", comment: "内部ストレージのラベル")
        case .sdCard:
            return NSLocalizedString("SDCard", comment: "SDカードのラベル")
        }
    }
}
