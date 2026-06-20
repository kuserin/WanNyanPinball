# 🐱🐶 Nyan & Wan Pinball — ベータ版 開発指示スクリプト

## プロジェクト概要

犬と猫をテーマにしたiOS向けピンボールゲーム。
ポケモンピンボール（GBC, 1999）をインスピレーション源とし、
Swift + SpriteKit で開発する。収益化はGoogle AdMobによる広告を使用。

---

## コンセプト

| 項目 | 内容 |
|------|------|
| アプリ名（仮） | Nyan & Wan Pinball |
| テーマ | 犬・猫の世界観 |
| ターゲット層 | 幅広い年齢層（ペット好き） |
| プラットフォーム | iOS |
| 言語 | Swift |
| 収益モデル | 無料 + Google AdMob 広告 |

---

## ゲームデザイン

### フィールド構成
- **猫フィールド（Nyan Stage）**: 室内・夜の雰囲気。毛玉バンパー、魚ターゲット
- **犬フィールド（Wan Stage）**: 公園・昼の雰囲気。ボーンバンパー、ボールターゲット

### ゲームギミック（ポケモンピンボール風）
- キャラクターコレクション要素（犬・猫の種類を集める）
- バンパーを一定数叩くとキャラクターが出現
- マルチボール、スロットボーナスなどのイベント

### ピンボール基本要素
- フリッパー（左右）
- バンパー（円形）
- スリングショット（三角）
- ターゲットレーン
- ドレイン（ボールロスト）

---

## 技術スタック

| 要素 | 技術 |
|------|------|
| 物理エンジン | SpriteKit + SKPhysicsBody |
| 広告SDK | Google AdMob（無料） |
| サウンド | AVFoundation |
| UI | SpriteKit Scene |
| アセット | SF Symbols + フリー素材 |

---

## ベータ版（コマンドライン）開発ステップ

### Step 1: プロジェクト初期化
```bash
# Xcodeプロジェクト作成（CLIベース）
mkdir NyanWanPinball
cd NyanWanPinball
swift package init --type executable
```

### Step 2: 物理エンジン基本実装
- `Ball.swift` : ボールの物理挙動（SKPhysicsBody, restitution, friction）
- `Flipper.swift` : フリッパーの回転・入力処理
- `Bumper.swift` : バンパーの衝突・スコア加算処理
- `GameScene.swift` : メインシーン、物理世界の初期化

### Step 3: フィールドレイアウト
- `CatField.swift` : 猫フィールドのレイアウト定義
- `DogField.swift` : 犬フィールドのレイアウト定義
- 各フィールドの壁・ガターの物理コライダー設定

### Step 4: ゲームロジック
- `GameManager.swift` : スコア管理、ボール残数、ステージ遷移
- `CharacterManager.swift` : キャラクターコレクション管理
- `BonusSystem.swift` : ボーナスイベント（マルチボール等）

### Step 5: 広告組み込み
- Google AdMob SDK 導入（CocoaPods or SPM）
- バナー広告: ゲームオーバー画面下部
- インタースティシャル広告: ステージクリア時

### Step 6: サウンド・エフェクト
- バンパーヒット音
- フリッパー操作音
- キャラクター出現時のSE
- BGM（猫フィールド・犬フィールドで異なる曲）

---

## ファイル構成（想定）

```
NyanWanPinball/
├── App/
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
├── Scenes/
│   ├── GameScene.swift       # メインゲームシーン
│   ├── MenuScene.swift       # タイトル画面
│   └── ResultScene.swift     # リザルト画面
├── Nodes/
│   ├── Ball.swift
│   ├── Flipper.swift
│   ├── Bumper.swift
│   └── Slingshot.swift
├── Fields/
│   ├── CatField.swift
│   └── DogField.swift
├── Managers/
│   ├── GameManager.swift
│   ├── CharacterManager.swift
│   ├── SoundManager.swift
│   └── AdManager.swift       # AdMob管理
├── Models/
│   ├── Character.swift       # 犬猫キャラクターモデル
│   └── Score.swift
└── Resources/
    ├── Assets.xcassets
    └── Sounds/
```

---

## スコアリング設計

| アクション | スコア |
|-----------|--------|
| バンパーヒット | +100pt |
| スリングショットヒット | +50pt |
| ターゲット全点灯 | +5,000pt |
| キャラクター出現 | +10,000pt |
| キャラクターキャッチ | +50,000pt |
| マルチボール | スコア×2 |

---

## AdMob 広告配置方針

| 広告種別 | 表示タイミング |
|---------|--------------|
| バナー広告 | ゲームオーバー画面・メニュー画面 |
| インタースティシャル | ステージクリア後（3回に1回） |
| リワード広告 | ボール追加（オプション） |

---

## 今後の拡張（v1.0以降）

- [ ] キャラクター図鑑（コレクション画面）
- [ ] Game Center ランキング
- [ ] 追加フィールドのDLC
- [ ] ハプティクスフィードバック（振動）
- [ ] iCloud セーブデータ同期

---

## 参考・インスピレーション

- ポケモンピンボール（任天堂 / ゲームボーイカラー, 1999）
  - 2フィールド構成
  - キャラクターコレクション要素
  - 振動ギミック
- Apple SpriteKit ドキュメント
- Google AdMob iOS スタートガイド
