extends Control

class_name StartScreen

# スタート画面のメインスクリプト

const GAME_VERSION := "ver0.002"
const TITLE_BGM_PATH := "res://assets/audio/bgm/bgm_title_screen.wav"
const DEFAULT_BGM_DB := 1.0
const GameManagerClass := preload("res://scripts/GameManager.gd")

@onready var version_label: Label = $VersionLabel
@onready var start_button = $MenuContainer/StartButton
@onready var continue_button = $MenuContainer/ContinueButton
@onready var gallery_button = $MenuContainer/GalleryButton

func _ready() -> void:
	setup_buttons()
	version_label.text = GAME_VERSION
	# キャラ立ち絵の透過処理
	$CharacterContainer/MizukiSprite.modulate.a = 1.0
	$CharacterContainer/SaoriSprite.modulate.a = 1.0
	var gm = GameManagerClass.instance
	var stream := load(TITLE_BGM_PATH) as AudioStream
	if gm and stream:
		gm.play_bgm(stream, DEFAULT_BGM_DB, true)
	elif not stream:
		push_warning("Title BGM not found or not an AudioStream: %s" % TITLE_BGM_PATH)
	check_save_data()

func setup_buttons():
	# ボタンのスタイル設定
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = Color(0.2, 0.2, 0.3, 0.8)
	button_style.border_width_left = 2
	button_style.border_width_right = 2
	button_style.border_width_top = 2
	button_style.border_width_bottom = 2
	button_style.border_color = Color(0.8, 0.8, 0.9, 1.0)
	button_style.corner_radius_top_left = 8
	button_style.corner_radius_top_right = 8
	button_style.corner_radius_bottom_left = 8
	button_style.corner_radius_bottom_right = 8
	
	var button_hover_style = StyleBoxFlat.new()
	button_hover_style.bg_color = Color(0.3, 0.3, 0.4, 0.9)
	button_hover_style.border_width_left = 2
	button_hover_style.border_width_right = 2
	button_hover_style.border_width_top = 2
	button_hover_style.border_width_bottom = 2
	button_hover_style.border_color = Color(0.9, 0.9, 1.0, 1.0)
	button_hover_style.corner_radius_top_left = 8
	button_hover_style.corner_radius_top_right = 8
	button_hover_style.corner_radius_bottom_left = 8
	button_hover_style.corner_radius_bottom_right = 8
	
	# 各ボタンにスタイルを適用
	for button in [start_button, continue_button, gallery_button]:
		button.add_theme_stylebox_override("normal", button_style)
		button.add_theme_stylebox_override("hover", button_hover_style)
		button.add_theme_color_override("font_color", Color.WHITE)
		button.add_theme_color_override("font_hover_color", Color.WHITE)

func check_save_data():
	# セーブデータの存在確認
	if GameManagerClass.instance and FileAccess.file_exists(GameManagerClass.SAVE_PATH):
		continue_button.disabled = false
		continue_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		continue_button.disabled = true
		continue_button.modulate = Color(0.6, 0.6, 0.6, 1.0)

# ボタンのシグナル処理
func _on_start_button_pressed():
	print("新しいゲームを開始します")
	# GameManagerの状態をリセットして新しいゲームを開始
	if GameManagerClass.instance:
		GameManagerClass.instance.stop_bgm() # BGMを停止
		GameManagerClass.instance.current_chapter = 0
		GameManagerClass.instance.current_scene = 0
		GameManagerClass.instance.character_affection = {"mizuki": 0, "saori": 0, "ruri": 0}
		GameManagerClass.instance.game_flags = {}
		GameManagerClass.instance.change_state(GameManagerClass.GameState.PLAYING)

	# ボタン群を非表示にする
	$MenuContainer.visible = false
	# メインゲームシーンに移行
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_continue_button_pressed():
	print("セーブデータからゲームを継続します")
	if GameManagerClass.instance:
		var save_data = GameManagerClass.instance.load_game()
		if save_data:
			GameManagerClass.instance.load_save_data(save_data)
			GameManagerClass.instance.change_state(GameManagerClass.GameState.PLAYING)
			get_tree().change_scene_to_file("res://scenes/Main.tscn")
		else:
			print("セーブデータが見つかりませんでした。")

func _on_gallery_button_pressed():
	print("ギャラリーを開きます (機能は開発中です)")
	# 将来的にギャラリーシーンに移行する処理をここに追加

# キーボード入力の処理
func _input(event):
	if event.is_action_pressed("ui_accept"):
		# Enterキーで「はじめから」を選択
		_on_start_button_pressed()
	elif event.is_action_pressed("ui_cancel"):
		# ESCキーでゲーム終了
		get_tree().quit()
