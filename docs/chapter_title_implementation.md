# 章タイトル表示機能の実装

## 概要

リファレンス画像を基に、ノクターンの章の始まりのタイトル表示機能を実装しました。

## デザイン仕様

リファレンス画像に基づき、以下のデザイン要素を実装しました:

1. **大きな日本語タイトル**: 画面中央に白い大きな文字（フォントサイズ80）で表示
2. **水平線**: タイトルの下に白い水平線（高さ3px、幅600px）
3. **英語サブタイトル**: 線の下に小さめの英語（フォントサイズ32）で表示
4. **背景**: 半透明の黒い背景（透明度0.6）でゲーム画面が透けて見える
5. **シャドウ効果**: テキストに影を追加して視認性を向上

## 実装内容

### 1. ChapterTitleシーン (`scenes/ChapterTitle.tscn`)

章タイトル表示用の独立したシーンを作成しました。以下のノード構造:

- **ChapterTitle** (Control): ルートノード
  - **Background** (ColorRect): 半透明の黒背景
  - **CenterContainer**: 中央配置用コンテナ
    - **TitleContainer** (VBoxContainer): タイトル要素の縦配置
      - **JapaneseTitle** (Label): 日本語タイトル
      - **Separator** (Panel): 水平線
      - **EnglishTitle** (Label): 英語タイトル
  - **AnimationPlayer**: アニメーション制御用（将来の拡張用）

### 2. ChapterTitleスクリプト (`scripts/ChapterTitle.gd`)

章タイトルの表示とアニメーションを制御するスクリプト:

**主要機能:**
- `show_chapter_title(jp_text, en_text, duration)`: タイトルを表示
- フェードイン/フェードアウトアニメーション（各1秒）
- 指定された時間表示後、自動的にフェードアウト
- Enterキーでスキップ可能
- `title_finished`シグナルで終了を通知

**パラメータ:**
- `jp_text`: 日本語タイトル
- `en_text`: 英語タイトル
- `duration`: 表示時間（デフォルト3秒）

### 3. Main.gdの更新

メインスクリプトに章タイトル機能を統合:

- `@onready var chapter_title: ChapterTitle`: ChapterTitleノードの参照を追加
- `_on_chapter_title_finished()`: タイトル表示終了後のハンドラを追加
- `_on_scenario_command()`: `show_chapter_title`コマンドの処理を追加
- シグナル接続: `chapter_title.title_finished.connect(_on_chapter_title_finished)`

### 4. Main.tscnの更新

メインシーンにChapterTitleノードを追加:

- UILayerの子として配置
- ChapterTitle.gdスクリプトをアタッチ
- 全画面表示の設定

### 5. シナリオファイルの更新

各章のJSONファイルに章タイトル表示コマンドを追加:

**chapter_01.json:**
```json
{
  "id": "C01-0000",
  "type": "show_chapter_title",
  "japanese_title": "持たざる者",
  "english_title": "CHAPTER 1  THE MEAGER",
  "duration": 3.0
}
```

**chapter_02.json:**
```json
{
  "id": "C02-0000",
  "type": "show_chapter_title",
  "japanese_title": "影の集会",
  "english_title": "CHAPTER 2  THE SHADOW ASSEMBLY",
  "duration": 3.0
}
```

**chapter_03.json:**
```json
{
  "id": "C03-0000",
  "type": "show_chapter_title",
  "japanese_title": "真実の扉",
  "english_title": "CHAPTER 3  THE DOOR TO TRUTH",
  "duration": 3.0
}
```

## 使用方法

### シナリオファイルでの使用

章の始まりに以下のコマンドを追加:

```json
{
  "id": "章ID-0000",
  "type": "show_chapter_title",
  "japanese_title": "日本語タイトル",
  "english_title": "ENGLISH TITLE",
  "duration": 3.0
}
```

### スクリプトからの直接呼び出し

```gdscript
chapter_title.show_chapter_title("日本語タイトル", "ENGLISH TITLE", 3.0)
```

## アニメーション仕様

1. **フェードイン**: 1秒かけて透明度0から1へ
2. **表示**: 指定された時間（デフォルト3秒）表示
3. **フェードアウト**: 1秒かけて透明度1から0へ
4. **スキップ**: Enterキーで0.3秒でフェードアウト

## 今後の拡張可能性

- より複雑なアニメーション（スライドイン、スケールなど）
- カスタムフォントの適用
- 章ごとに異なる背景色やエフェクト
- サウンドエフェクトの追加
- より詳細なスキップ制御

## 技術的な注意点

1. ChapterTitleは初期状態で非表示（`hide()`）
2. `modulate.a`を使用してフェード効果を実現
3. Tweenを使用してスムーズなアニメーション
4. シグナルベースの非同期処理でシナリオフローと統合
5. 入力処理は`_input()`で実装し、`set_input_as_handled()`で伝播を防止

## ファイル一覧

**新規作成:**
- `scenes/ChapterTitle.tscn`
- `scripts/ChapterTitle.gd`
- `scripts/ChapterTitle.gd.uid`

**更新:**
- `scripts/Main.gd`
- `scenes/Main.tscn`
- `data/scenarios/chapter_01.json`
- `data/scenarios/chapter_02.json`
- `data/scenarios/chapter_03.json`

