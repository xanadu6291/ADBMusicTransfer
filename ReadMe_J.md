[Japanese][[English](README.md)]

# ADBMusicTransfer

ADBMusicTransfer は macOS 向けのシンプルな GUI アプリで、音楽ファイルを ADB 経由で Android デバイスに転送するツールです。  
MIT ライセンスのもと、オープンソースとして公開しています。

## 🔧 機能

- ADB デバイスの検出と接続確認
- アーティスト名・アルバム名のオートコンプリート
- 音楽ファイルの指定および Android デバイスへの転送
- 公証済みアプリ（macOS の Gatekeeper 対応）

## 📦 ビルド方法

1. [Xcode](https://developer.apple.com/xcode/) をインストール
2. 本リポジトリをクローン：
   ```bash
   git clone https://github.com/xanadu6291/ADBMusicTransfer.git
   cd ADBMusicTransfer
3. ADBMusicTransfer.xcodeproj を開く
4.	Cmd + R でビルド＆実行！

## 🛠 依存
	•	macOS 12.0+
	•	ADB コマンドラインツール（インストールされている必要があります）
	•	[Android SDK Platform Tools](https://developer.android.com/studio/releases/platform-tools)

## 📄 ライセンス

MIT License を採用しています。詳細は [LICENSE](LICENSE) をご確認ください。