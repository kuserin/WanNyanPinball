# NyanWanPinball — Xcode セットアップ手順

## 1. Xcodeプロジェクト作成

1. Xcode を開く → **File > New > Project**
2. **iOS > App** を選択
3. 設定:
   - Product Name: `NyanWanPinball`
   - Bundle Identifier: `com.yourname.NyanWanPinball`
   - Interface: **Storyboard** → **UIKit App Delegate** を選択  
     *(SceneDelegate.swift を使うため)*
   - Language: **Swift**
4. 保存場所をこのフォルダと同じ場所に指定

## 2. 既存ファイルを追加

Xcodeプロジェクトに以下のフォルダをドラッグ&ドロップ（**Copy items if needed** をチェック）:

```
App/
Scenes/
Nodes/
Fields/
Managers/
Models/
```

- **Create groups** を選択（黄色フォルダアイコン）

## 3. 不要なデフォルトファイルを削除

Xcodeが自動生成する以下を削除:
- `ContentView.swift`（SwiftUIの場合）
- `ViewController.swift`（使わない場合）
- `Main.storyboard`（SceneDelegate経由で起動するため）

`Info.plist` の `Main storyboard file base name` エントリも削除する。

## 4. Info.plist に Scene 設定を追加

```xml
<key>UIApplicationSceneManifest</key>
<dict>
    <key>UIApplicationSupportsMultipleScenes</key>
    <false/>
    <key>UISceneConfigurations</key>
    <dict>
        <key>UIWindowSceneSessionRoleApplication</key>
        <array>
            <dict>
                <key>UISceneConfigurationName</key>
                <string>Default Configuration</string>
                <key>UISceneDelegateClassName</key>
                <string>$(PRODUCT_MODULE_NAME).SceneDelegate</string>
            </dict>
        </array>
    </dict>
</dict>
```

## 5. サウンドファイルを追加（Step 6 以降）

`Resources/Sounds/` に以下を配置:
- `bumper_hit.wav`
- `flipper.wav`
- `char_appear.wav`
- `drain.wav`
- `bgm_cat.mp3`
- `bgm_dog.mp3`

## 6. AdMob SDK 導入（Step 5）

### CocoaPods の場合

```ruby
# Podfile
platform :ios, '14.0'
target 'NyanWanPinball' do
  pod 'Google-Mobile-Ads-SDK'
end
```

```bash
pod install
# 以降は .xcworkspace を使う
```

### Swift Package Manager の場合

Xcode → **File > Add Package Dependencies** →
`https://github.com/googleads/swift-package-manager-google-mobile-ads`

SDK 追加後、`AdManager.swift` のコメントアウト部分を有効化する。

## 7. ビルド & 実行

1. シミュレータ（iPhone 14 推奨）を選択
2. `⌘+R` でビルド＆実行
3. 画面左半分タップ → 左フリッパー
4. 画面右半分タップ → 右フリッパー

## ファイル構成

```
NyanWanPinball/
├── App/
│   ├── AppDelegate.swift       # アプリ起動・AdMob初期化
│   └── SceneDelegate.swift     # ウィンドウ管理・GameViewController
├── Scenes/
│   ├── GameScene.swift         # メインゲームシーン（物理・入力・HUD）
│   ├── MenuScene.swift         # タイトル画面
│   └── ResultScene.swift       # リザルト画面
├── Nodes/
│   ├── Ball.swift              # ボール（物理・描画）
│   ├── Flipper.swift           # フリッパー（左右・アクション）
│   ├── Bumper.swift            # バンパー（ヒット・スコア加算）
│   └── Slingshot.swift         # スリングショット
├── Fields/
│   ├── CatField.swift          # 猫フィールド装飾・魚ターゲット
│   └── DogField.swift          # 犬フィールド装飾・骨ターゲット
├── Managers/
│   ├── GameManager.swift       # スコア・ボール残数・マルチプライヤー
│   ├── CharacterManager.swift  # キャラクターコレクション管理
│   ├── SoundManager.swift      # BGM・SE 再生（AVFoundation + SKAction）
│   └── AdManager.swift         # AdMob バナー・インタースティシャル・リワード
└── Models/
    ├── Character.swift         # キャラクターモデル（猫5種・犬5種）
    └── Score.swift             # スコア保存（UserDefaults）
```
