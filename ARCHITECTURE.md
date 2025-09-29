# アーキテクチャ設計書

## 🏗️ システム全体構成

### アーキテクチャ概要
```
┌─────────────────────────────────────────────────────────────┐
│                        Main Scene                           │
├─────────────────────────────────────────────────────────────┤
│  GameManager (Singleton)                                    │
│  ├── ゲーム状態管理                                         │
│  ├── フラグ・好感度管理                                     │
│  └── 設定管理                                               │
├─────────────────────────────────────────────────────────────┤
│  ScenarioManager                                            │
│  ├── シナリオデータ管理                                     │
│  ├── コマンド実行                                           │
│  └── 進行制御                                               │
├─────────────────────────────────────────────────────────────┤
│  CharacterManager                                           │
│  ├── キャラクター表示                                       │
│  ├── 表情変更                                               │
│  └── アニメーション制御                                     │
├─────────────────────────────────────────────────────────────┤
│  DialogSystem                                               │
│  ├── テキスト表示                                           │
│  ├── タイピング効果                                         │
│  └── 選択肢処理                                             │
├─────────────────────────────────────────────────────────────┤
│  SaveSystem                                                 │
│  ├── セーブデータ管理                                       │
│  ├── ファイルI/O                                           │
│  └── スロット管理                                           │
└─────────────────────────────────────────────────────────────┘
```

## 📁 フォルダレイアウト

### プロジェクト構造の詳細

```
Detective-Nocturne/
├── project.godot                    # Godotプロジェクト設定ファイル
├── icon.svg                         # プロジェクトアイコン
│
├── scenes/                          # シーンファイル群
│   ├── Main.tscn                   # メインシーン（ゲームのエントリーポイント）
│   ├── ui/                         # UIシーン群
│   │   ├── DialogSystem.tscn       # ダイアログシステム
│   │   ├── MenuSystem.tscn         # メニューシステム
│   │   ├── SaveLoadSystem.tscn     # セーブ・ロードUI
│   │   └── SettingsSystem.tscn     # 設定画面
│   ├── characters/                 # キャラクターシーン群
│   │   ├── Mizuki.tscn            # みずきキャラクター
│   │   ├── Saori.tscn             # 沙織キャラクター
│   │   └── Ruri.tscn              # 瑠璃キャラクター
│   └── backgrounds/                # 背景シーン群
│       ├── DetectiveOffice.tscn    # 探偵事務所
│       ├── TanakaBookstore.tscn    # 田中書店
│       └── HasegawaAntiques.tscn   # 長谷川古美術
│
├── scripts/                        # スクリプトファイル群
│   ├── GameManager.gd              # ゲーム全体管理（シングルトン）
│   ├── DialogSystem.gd             # ダイアログシステム制御
│   ├── CharacterManager.gd         # キャラクター表示・管理
│   ├── ScenarioManager.gd          # シナリオ進行制御
│   ├── SaveSystem.gd               # セーブ・ロードシステム
│   ├── SettingsSystem.gd           # 設定システム
│   └── Main.gd                     # メインシーン制御
│
├── assets/                         # アセットファイル群
│   ├── images/                     # 画像ファイル
│   │   ├── characters/             # キャラクター画像
│   │   │   ├── mizuki/            # みずきの立ち絵・表情
│   │   │   ├── saori/             # 沙織の立ち絵・表情
│   │   │   └── ruri/              # 瑠璃の立ち絵・表情
│   │   ├── backgrounds/            # 背景画像
│   │   │   ├── detective_office/  # 探偵事務所背景
│   │   │   ├── bookstore/         # 書店背景
│   │   │   └── antique_shop/      # 古美術店背景
│   │   ├── ui/                    # UI画像
│   │   │   ├── dialog_box.png     # ダイアログボックス
│   │   │   ├── buttons/           # ボタン画像
│   │   │   └── icons/             # アイコン画像
│   │   └── cg/                    # CG画像（18禁シーン含む）
│   ├── audio/                     # 音声ファイル
│   │   ├── bgm/                   # BGM
│   │   │   ├── daily.ogg          # 日常BGM
│   │   │   ├── mystery.ogg        # ミステリーBGM
│   │   │   └── climax.ogg         # クライマックスBGM
│   │   ├── se/                    # 効果音
│   │   │   ├── click.ogg          # クリック音
│   │   │   ├── door.ogg           # ドア音
│   │   │   └── phone.ogg          # 電話音
│   │   └── voice/                 # ボイス（将来実装）
│   │       ├── mizuki/            # みずきボイス
│   │       ├── saori/             # 沙織ボイス
│   │       └── ruri/              # 瑠璃ボイス
│   └── fonts/                     # フォントファイル
│       ├── main_font.ttf          # メインフォント
│       └── dialog_font.ttf        # ダイアログフォント
│
└── data/                          # データファイル群
    ├── scenarios/                 # シナリオデータ
    │   ├── prologue.json          # 序章シナリオ
    │   ├── chapter01.json         # 第一章シナリオ
    │   └── ...                    # その他の章
    ├── characters/                # キャラクターデータ
    │   ├── mizuki.json            # みずき設定
    │   ├── saori.json             # 沙織設定
    │   └── ruri.json              # 瑠璃設定
    └── saves/                     # セーブデータ（実行時生成）
        ├── save_0.dat             # セーブスロット0
        └── ...                    # その他のスロット
```

## 🔧 機能モジュールパターン

### 1. GameManager（シングルトン）
```gdscript
# 責務
- ゲーム全体の状態管理
- フラグ・好感度システム
- 設定データ管理
- シーン間データ共有

# 主要メソッド
- change_state(new_state)
- set_flag(flag_name, value)
- change_affection(character, amount)
- create_save_data()
- load_save_data(data)
```

### 2. ScenarioManager
```gdscript
# 責務
- シナリオデータの読み込み・管理
- シナリオコマンドの実行
- 分岐・選択肢の処理
- 進行状況の管理

# 主要メソッド
- start_scenario(scenario_name)
- execute_next_command()
- advance_scenario()
- handle_choice(choice_index)
```

### 3. CharacterManager
```gdscript
# 責務
- キャラクター立ち絵の表示・非表示
- 表情変更・アニメーション
- 位置管理・レイヤー制御
- プレースホルダー画像生成

# 主要メソッド
- show_character(name, position, expression)
- hide_character(name)
- change_expression(name, expression)
- create_placeholder_texture(name, expression)
```

### 4. DialogSystem
```gdscript
# 責務
- テキストの表示・タイピング効果
- キャラクター名表示
- 選択肢UI
- バックログ管理

# 主要メソッド
- start_dialog(dialog_data)
- start_typing(text)
- show_choices(choices)
- toggle_dialog_box()
```

### 5. SaveSystem
```gdscript
# 責務
- セーブデータの保存・読み込み
- スロット管理
- ファイルI/O処理
- データ整合性チェック

# 主要メソッド
- save_game(slot)
- load_game(slot)
- get_save_info(slot)
- delete_save(slot)
```

## 📊 データスキーマポリシー

### シナリオデータ構造
```json
{
  "type": "dialog|narration|show_character|change_expression|choice",
  "speaker": "キャラクター名",
  "text": "表示テキスト",
  "character": "キャラクター識別子",
  "position": "left|center|right|far_left|far_right",
  "expression": "normal|smile|sad|angry|surprised",
  "choices": [
    {
      "text": "選択肢テキスト",
      "flag": "設定するフラグ",
      "affection": {"character": "amount"}
    }
  ]
}
```

### セーブデータ構造
```json
{
  "chapter": 0,
  "scene": 0,
  "affection": {
    "mizuki": 0,
    "saori": 0,
    "ruri": 0
  },
  "flags": {
    "flag_name": true
  },
  "settings": {
    "master_volume": 1.0,
    "text_speed": 1.0
  },
  "timestamp": 1234567890
}
```

### キャラクターデータ構造
```json
{
  "name": "キャラクター名",
  "display_name": "表示名",
  "color": "#FFFFFF",
  "expressions": ["normal", "smile", "sad", "angry", "surprised"],
  "default_position": "center",
  "voice_prefix": "mizuki_"
}
```

## 🔄 システム間連携

### シグナル・イベントフロー
```
User Input → Main Scene → ScenarioManager
                ↓
ScenarioManager → CharacterManager (キャラクター表示)
                ↓
ScenarioManager → DialogSystem (テキスト表示)
                ↓
DialogSystem → Main Scene (完了通知)
                ↓
Main Scene → ScenarioManager (次のコマンド実行)
```

### 状態管理フロー
```
GameManager.current_state:
  MENU → PLAYING → DIALOG → PLAYING
    ↑                         ↓
    ←─────── PAUSED ←─────────
```

## 🎯 パフォーマンス考慮事項

### メモリ管理
- **キャラクター画像**: 動的ロード・アンロード
- **背景画像**: シーン切り替え時に管理
- **音声ファイル**: ストリーミング再生
- **セーブデータ**: 必要時のみメモリ展開

### ファイルI/O最適化
- **非同期読み込み**: 大きなアセットファイル
- **キャッシュ機能**: 頻繁にアクセスするデータ
- **圧縮**: 画像・音声ファイルの最適化

### レンダリング最適化
- **レイヤー管理**: UI・キャラクター・背景の分離
- **カリング**: 画面外オブジェクトの非描画
- **バッチング**: 同種オブジェクトの一括描画

## 🔐 セキュリティ・整合性

### セーブデータ保護
- **チェックサム**: データ改ざん検出
- **バージョン管理**: 互換性チェック
- **暗号化**: 重要データの保護（将来実装）

### 18禁コンテンツ管理
- **年齢確認**: 起動時チェック
- **コンテンツフィルタ**: 地域対応
- **アクセス制御**: 適切な警告表示

---

この設計に基づいて、拡張性と保守性を重視したゲームシステムを構築しています。
