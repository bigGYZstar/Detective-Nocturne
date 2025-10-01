extends Control

class_name StartScreen

# スタート画面のメインスクリプト

@onready var start_button = $MenuContainer/StartButton
@onready var continue_button = $MenuContainer/ContinueButton
@onready var gallery_button = $MenuContainer/GalleryButton

func _ready():
	# ボタンの初期設定
	setup_buttons()
	
	# セーブデータの存在確認
	check_save_data()
	
	# 自動的にゲームを開始（テスト用）
	call_deferred("_on_start_button_pressed")

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
	# セーブデータの存在確認（実装予定）
	# 現在は「つづきから」ボタンを無効化
	continue_button.disabled = true
	continue_button.modulate = Color(0.6, 0.6, 0.6, 1.0)

# ボタンのシグナル処理
func _on_start_button_pressed():
	print("新しいゲームを開始します")
	# GameManagerの状態をリセットして新しいゲームを開始
	if GameManager.instance:
		GameManager.instance.current_chapter = 0
		GameManager.instance.current_scene = 0
		GameManager.instance.character_affection = {"mizuki": 0, "saori": 0, "ruri": 0}
		GameManager.instance.game_flags = {}
		GameManager.instance.change_state(GameManager.GameState.PLAYING)
	
	# メインゲームシーンに移行
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_continue_button_pressed():
	print("セーブデータからゲームを継続します")
	# セーブデータの読み込み処理（実装予定）
	print("セーブデータ機能は開発中です")

func _on_gallery_button_pressed():
	print("ギャラリーを開きます")
	# ギャラリーシーンに移行（実装予定）
	print("ギャラリー機能は開発中です")

# キーボード入力の処理
func _input(event):
	if event.is_action_pressed("ui_accept"):
		# Enterキーで「はじめから」を選択
		_on_start_button_pressed()
	elif event.is_action_pressed("ui_cancel"):
		# ESCキーでゲーム終了
		get_tree().quit()
