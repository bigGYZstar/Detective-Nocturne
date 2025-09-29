# コントリビューションガイド

## 🤝 プロジェクトへの貢献について

探偵ノクターン -銀の黄昏とアザゼルの鍵- プロジェクトへの貢献に興味を持っていただき、ありがとうございます。

## 📋 コーディングルール

### GDScript スタイルガイド

#### 命名規則
```gdscript
# クラス名: PascalCase
class_name GameManager

# 変数名: snake_case
var current_state: GameState
var character_affection: Dictionary

# 定数名: UPPER_SNAKE_CASE
const MAX_SAVE_SLOTS = 10
const SAVE_FILE_PATH = "user://save_data_%d.dat"

# 関数名: snake_case
func change_state(new_state: GameState):
func get_affection(character: String) -> int:

# シグナル名: snake_case
signal dialog_finished
signal character_animation_finished

# 列挙型: PascalCase
enum GameState {
    MENU,
    PLAYING,
    PAUSED
}
```

#### インデント・フォーマット
- **インデント**: タブ文字を使用
- **行の長さ**: 100文字以内を推奨
- **空行**: 関数間に1行、クラス間に2行
- **コメント**: 日本語で記述、複雑な処理には必須

```gdscript
# 良い例
func start_dialog(dialog_data: Array):
    current_dialog = dialog_data
    current_index = 0
    show()
    GameManager.instance.change_state(GameManager.GameState.DIALOG)
    display_current_dialog()

# 悪い例
func start_dialog(dialog_data:Array):
current_dialog=dialog_data
current_index=0
show()
GameManager.instance.change_state(GameManager.GameState.DIALOG)
display_current_dialog()
```

#### 型注釈
- 可能な限り型注釈を使用
- 戻り値の型も明記

```gdscript
# 良い例
func get_save_info(slot: int) -> Dictionary:
    var save_data: Dictionary = {}
    return save_data

# 悪い例
func get_save_info(slot):
    var save_data = {}
    return save_data
```

### ファイル構成ルール

#### シーンファイル (.tscn)
- **命名**: PascalCase（例: `DialogSystem.tscn`）
- **構造**: 論理的な階層構造を維持
- **ノード名**: 機能を表す明確な名前

#### スクリプトファイル (.gd)
- **命名**: PascalCase（例: `GameManager.gd`）
- **ヘッダー**: クラスの説明コメント
- **構造**: 定数 → 変数 → シグナル → 関数の順

```gdscript
extends Node

# ゲーム全体を管理するシングルトンクラス
class_name GameManager

# 定数
const MAX_SAVE_SLOTS = 10

# 変数
var current_state: GameState = GameState.MENU

# シグナル
signal state_changed(new_state: GameState)

# 関数
func _ready():
    # 初期化処理
    pass
```

## 📝 コミット規約

### コミットメッセージ形式
```
<type>(<scope>): <subject>

<body>

<footer>
```

#### Type（必須）
- **feat**: 新機能追加
- **fix**: バグ修正
- **docs**: ドキュメント変更
- **style**: コードフォーマット変更
- **refactor**: リファクタリング
- **test**: テスト追加・修正
- **chore**: ビルド・設定変更

#### Scope（任意）
- **ui**: UIシステム
- **dialog**: ダイアログシステム
- **character**: キャラクター管理
- **scenario**: シナリオシステム
- **save**: セーブシステム
- **audio**: 音響システム

#### 例
```bash
feat(dialog): タイピング効果の実装

ダイアログテキストにタイピング効果を追加
- 文字単位での段階的表示
- 速度調整機能
- スキップ機能

Closes #123
```

### ブランチ戦略

#### ブランチ命名規則
- **feature/**: 新機能開発 (`feature/dialog-system`)
- **fix/**: バグ修正 (`fix/save-corruption`)
- **docs/**: ドキュメント (`docs/api-reference`)
- **refactor/**: リファクタリング (`refactor/character-manager`)

#### ワークフロー
1. `main`ブランチから新しいブランチを作成
2. 機能開発・修正を実施
3. プルリクエストを作成
4. レビュー後にマージ

## 🧪 テスト方針

### テスト実行
```bash
# Godotプロジェクトのインポートテスト
./Godot_v4.3-stable_linux.x86_64 --headless --quit --path . --import

# 基本動作テスト
./Godot_v4.3-stable_linux.x86_64 --headless --path . --main-pack game.pck
```

### テストケース
- **シナリオ進行**: 各章の正常動作
- **セーブ・ロード**: データ整合性
- **キャラクター表示**: 表情・位置変更
- **UI操作**: ダイアログ・メニュー

## 📁 ファイル追加ガイドライン

### アセットファイル
```
assets/
├── images/
│   ├── characters/
│   │   └── [character_name]/
│   │       ├── normal.png
│   │       ├── smile.png
│   │       └── ...
│   └── backgrounds/
│       └── [scene_name]/
└── audio/
    ├── bgm/
    └── se/
```

### データファイル
```
data/
├── scenarios/
│   └── [chapter_name].json
├── characters/
│   └── [character_name].json
└── saves/
    └── .gitkeep
```

## 🔍 コードレビュー基準

### チェックポイント
- [ ] コーディングルールに準拠
- [ ] 適切な型注釈
- [ ] 必要なコメント
- [ ] パフォーマンス考慮
- [ ] セキュリティ考慮
- [ ] テスト実行確認

### レビュー観点
1. **機能性**: 要件を満たしているか
2. **可読性**: コードが理解しやすいか
3. **保守性**: 将来の変更に対応できるか
4. **パフォーマンス**: 適切な処理速度か
5. **セキュリティ**: 脆弱性がないか

## 🚀 リリースプロセス

### バージョニング
セマンティックバージョニング（SemVer）を採用
- **MAJOR**: 互換性のない変更
- **MINOR**: 後方互換性のある機能追加
- **PATCH**: 後方互換性のあるバグ修正

例: `v0.1.0` → `v0.2.0` → `v1.0.0`

### リリース手順
1. バージョンタグの作成
2. リリースノートの作成
3. ビルドファイルの生成
4. GitHubリリースの公開

## 📞 サポート・質問

### 連絡方法
- **GitHub Issues**: バグ報告・機能要望
- **GitHub Discussions**: 一般的な質問・議論
- **Pull Request**: コード変更提案

### 質問テンプレート
```markdown
## 質問内容
[具体的な質問内容]

## 環境情報
- OS: 
- Godot Version: 
- プロジェクトバージョン: 

## 再現手順
1. 
2. 
3. 

## 期待する動作
[期待する結果]

## 実際の動作
[実際の結果]
```

---

このガイドラインに従って、品質の高いコードとプロジェクトの発展にご協力ください。
