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
	print("[StartScreen] _ready() called - ensuring start UI visible")
	self.show()
	self.visible = true
	print("[StartScreen] Root node visibility: %s" % str(self.visible))
	$MenuContainer.show()
	$MenuContainer.visible = true
	print("[StartScreen] MenuContainer visibility: %s" % str($MenuContainer.visible))
	if start_button:
		start_button.show()
		start_button.disabled = false
		print("[StartScreen] Start button shown and enabled (visible=%s disabled=%s)" % [str(start_button.visible), str(start_button.disabled)])
	else:
		printerr("[StartScreen] Start button reference missing")
	setup_buttons()
	print("[StartScreen] Menu and start button forced visible/enabled in _ready.")
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
func _on_start_button_pressed() -> void:
	print("[StartScreen] Start button pressed. Beginning game start sequence.")
	var tree := get_tree()
	var root := tree.get_root()
	var gm := GameManagerClass.instance

	if gm == null:
		var gm_node := GameManagerClass.new()
		root.add_child(gm_node)
		print("[StartScreen] GameManager created and awaiting _ready()")
		await tree.process_frame
		gm = GameManagerClass.instance

	if gm:
		print("[StartScreen] GameManager initialized - switching to PLAYING")
		gm.stop_bgm()
		gm.current_chapter = 0
		gm.current_scene = 0
		gm.character_affection = {"mizuki": 0, "saori": 0, "ruri": 0}
		gm.game_flags = {}
		gm.change_state(GameManagerClass.GameState.PLAYING)
	else:
		printerr("[StartScreen] Failed to initialize GameManager; aborting scene change.")
		return

	print("[StartScreen] Hiding menu and start button")
	$MenuContainer.hide()
	if start_button:
		start_button.hide()
		start_button.disabled = true

	await tree.process_frame
	print("[StartScreen] Changing scene to Main.tscn now.")
	tree.change_scene_to_file("res://scenes/Main.tscn")

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
