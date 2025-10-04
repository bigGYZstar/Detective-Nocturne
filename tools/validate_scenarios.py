#!/usr/bin/env python3
"""
Detective-Nocturne シナリオデータバリデーター

このスクリプトは、data/scenarios/*.json ファイルを読み込み、以下の項目をチェックします:
- schema_version と id の存在
- 行ID重複
- 未定義ジャンプ
- 未使用ラベル
- bg/pose/bgm/sfx/voice のmanifest未登録キー
"""

import json
import sys
from pathlib import Path
from typing import Dict, List, Set, Tuple

# プロジェクトルートディレクトリ
PROJECT_ROOT = Path(__file__).parent.parent

def load_json(filepath: Path) -> Dict:
    """JSONファイルを読み込む"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return json.load(f)
    except json.JSONDecodeError as e:
        print(f"❌ JSONパースエラー: {filepath}")
        print(f"   {e}")
        return None
    except FileNotFoundError:
        print(f"❌ ファイルが見つかりません: {filepath}")
        return None

def validate_chapter_schema(chapter_data: Dict, chapter_file: Path) -> List[str]:
    """章JSONのスキーマ宣言とIDを検証"""
    errors = []
    
    if 'schema_version' not in chapter_data:
        errors.append(f"❌ {chapter_file.name}: 'schema_version' フィールドが存在しません")
    
    if 'id' not in chapter_data:
        errors.append(f"❌ {chapter_file.name}: 'id' フィールドが存在しません")
    
    if 'lines' not in chapter_data:
        errors.append(f"❌ {chapter_file.name}: 'lines' フィールドが存在しません")
    
    return errors

def validate_line_ids(chapter_data: Dict, chapter_file: Path) -> List[str]:
    """行IDの重複を検証"""
    errors = []
    seen_ids = set()
    
    lines = chapter_data.get('lines', [])
    for idx, line in enumerate(lines):
        line_id = line.get('id')
        if not line_id:
            errors.append(f"❌ {chapter_file.name}: 行 {idx} に 'id' フィールドがありません")
            continue
        
        if line_id in seen_ids:
            errors.append(f"❌ {chapter_file.name}: 行ID '{line_id}' が重複しています")
        else:
            seen_ids.add(line_id)
    
    return errors

def collect_labels_and_jumps(chapter_data: Dict) -> Tuple[Set[str], Set[str]]:
    """ラベルとジャンプ先を収集"""
    labels = set()
    jumps = set()
    
    lines = chapter_data.get('lines', [])
    for line in lines:
        line_type = line.get('type')
        
        if line_type == 'label':
            label_name = line.get('name')
            if label_name:
                labels.add(label_name)
        
        if line_type == 'jump':
            target = line.get('target')
            if target:
                jumps.add(target)
    
    return labels, jumps

def validate_jumps(chapter_data: Dict, chapter_file: Path) -> List[str]:
    """未定義ジャンプと未使用ラベルを検証"""
    errors = []
    labels, jumps = collect_labels_and_jumps(chapter_data)
    
    # 未定義ジャンプ
    undefined_jumps = jumps - labels
    for jump in undefined_jumps:
        errors.append(f"⚠️  {chapter_file.name}: 未定義のジャンプ先 '{jump}' が参照されています")
    
    # 未使用ラベル
    unused_labels = labels - jumps
    for label in unused_labels:
        errors.append(f"ℹ️  {chapter_file.name}: ラベル '{label}' は使用されていません（情報）")
    
    return errors

def collect_asset_references(chapter_data: Dict) -> Dict[str, Set[str]]:
    """シナリオ内で参照されているアセットキーを収集"""
    references = {
        'characters': set(),
        'bg': set(),
        'bgm': set(),
        'sfx': set(),
        'voice': set()
    }
    
    lines = chapter_data.get('lines', [])
    for line in lines:
        line_type = line.get('type')
        
        # キャラクター参照
        if line_type in ['show_character', 'change_expression', 'hide_character']:
            character = line.get('character')
            expression = line.get('expression')
            if character:
                if expression:
                    references['characters'].add(f"{character}.{expression}")
                else:
                    references['characters'].add(character)
        
        # 背景参照
        if line_type == 'change_background':
            bg = line.get('background')
            if bg:
                references['bg'].add(bg)
        
        # BGM参照
        if line_type == 'play_bgm':
            bgm = line.get('bgm')
            if bgm:
                references['bgm'].add(bgm)
        
        # SE参照
        if line_type == 'play_se':
            se = line.get('se')
            if se:
                references['sfx'].add(se)
        
        # ボイス参照
        if line_type == 'play_voice':
            voice = line.get('voice')
            if voice:
                references['voice'].add(voice)
    
    return references

def validate_asset_references(chapter_data: Dict, manifest_data: Dict, chapter_file: Path) -> List[str]:
    """アセット参照がmanifestに登録されているか検証"""
    errors = []
    references = collect_asset_references(chapter_data)
    
    # キャラクター参照の検証
    for char_ref in references['characters']:
        parts = char_ref.split('.')
        if len(parts) == 2:
            character, expression = parts
            if character not in manifest_data.get('characters', {}):
                errors.append(f"❌ {chapter_file.name}: キャラクター '{character}' がmanifest.jsonに登録されていません")
            elif expression not in manifest_data.get('characters', {}).get(character, {}):
                errors.append(f"❌ {chapter_file.name}: キャラクター '{character}' の表情 '{expression}' がmanifest.jsonに登録されていません")
        else:
            if char_ref not in manifest_data.get('characters', {}):
                errors.append(f"❌ {chapter_file.name}: キャラクター '{char_ref}' がmanifest.jsonに登録されていません")
    
    # 背景参照の検証
    for bg_ref in references['bg']:
        if bg_ref not in manifest_data.get('bg', {}):
            errors.append(f"❌ {chapter_file.name}: 背景 '{bg_ref}' がmanifest.jsonに登録されていません")
    
    # BGM参照の検証
    for bgm_ref in references['bgm']:
        if bgm_ref not in manifest_data.get('bgm', {}):
            errors.append(f"❌ {chapter_file.name}: BGM '{bgm_ref}' がmanifest.jsonに登録されていません")
    
    # SE参照の検証
    for sfx_ref in references['sfx']:
        if sfx_ref not in manifest_data.get('sfx', {}):
            errors.append(f"❌ {chapter_file.name}: SE '{sfx_ref}' がmanifest.jsonに登録されていません")
    
    # ボイス参照の検証
    for voice_ref in references['voice']:
        if voice_ref not in manifest_data.get('voice', {}):
            errors.append(f"❌ {chapter_file.name}: ボイス '{voice_ref}' がmanifest.jsonに登録されていません")
    
    return errors

def validate_text_fields(chapter_data: Dict, chapter_file: Path) -> List[str]:
    """textフィールドの多言語辞書形式を検証"""
    errors = []
    
    lines = chapter_data.get('lines', [])
    for idx, line in enumerate(lines):
        if 'text' in line:
            text = line['text']
            if isinstance(text, dict):
                # 多言語辞書形式の場合、少なくとも1つの言語が必要
                if not text:
                    errors.append(f"⚠️  {chapter_file.name}: 行 {idx} (ID: {line.get('id')}): textフィールドが空の辞書です")
            elif not isinstance(text, str):
                errors.append(f"❌ {chapter_file.name}: 行 {idx} (ID: {line.get('id')}): textフィールドは文字列または辞書である必要があります")
    
    return errors

def main():
    """メイン処理"""
    print("🔍 Detective-Nocturne シナリオデータバリデーター\n")
    
    # manifestファイルの読み込み
    manifest_path = PROJECT_ROOT / 'data' / 'assets' / 'manifest.json'
    manifest_data = load_json(manifest_path)
    if manifest_data is None:
        print("❌ manifest.jsonの読み込みに失敗しました")
        sys.exit(1)
    
    print(f"✅ manifest.json を読み込みました\n")
    
    # シナリオファイルの検証
    scenarios_dir = PROJECT_ROOT / 'data' / 'scenarios'
    chapter_files = sorted(scenarios_dir.glob('*.json'))
    
    if not chapter_files:
        print(f"⚠️  {scenarios_dir} にシナリオファイルが見つかりません")
        sys.exit(0)
    
    all_errors = []
    
    for chapter_file in chapter_files:
        print(f"📖 {chapter_file.name} を検証中...")
        
        chapter_data = load_json(chapter_file)
        if chapter_data is None:
            all_errors.append(f"❌ {chapter_file.name}: ファイルの読み込みに失敗しました")
            continue
        
        # スキーマ検証
        errors = validate_chapter_schema(chapter_data, chapter_file)
        all_errors.extend(errors)
        
        # 行ID検証
        errors = validate_line_ids(chapter_data, chapter_file)
        all_errors.extend(errors)
        
        # ジャンプ検証
        errors = validate_jumps(chapter_data, chapter_file)
        all_errors.extend(errors)
        
        # アセット参照検証
        errors = validate_asset_references(chapter_data, manifest_data, chapter_file)
        all_errors.extend(errors)
        
        # テキストフィールド検証
        errors = validate_text_fields(chapter_data, chapter_file)
        all_errors.extend(errors)
        
        print()
    
    # 結果の出力
    print("=" * 60)
    if all_errors:
        print(f"\n⚠️  {len(all_errors)} 件の問題が見つかりました:\n")
        for error in all_errors:
            print(error)
        print()
        sys.exit(1)
    else:
        print("\n✅ すべての検証に合格しました！\n")
        sys.exit(0)

if __name__ == '__main__':
    main()
