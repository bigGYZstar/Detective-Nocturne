extends Control

# メインシーンコントローラー
@onready var dialog_system: DialogSystem = $UILayer/DialogSystem
@onready var character_manager = $CharacterManager
@onready var scenario_manager: ScenarioManager = $ScenarioManager
@onready var start_button: Button = $MenuLayer/StartButton
@onready var menu_layer: CanvasLayer = $MenuLayer
@onready var chapter_title: ChapterTitle = $UILayer/ChapterTitle

# 現在のダイアログデータ
var current_dialog_data: Array = []

func _ready():
	print("[Main] _ready() called. GameManager.instance:", GameManager.instance)
	if GameManager.instance:
		print("[Main] GameManager.current_state:", GameManager.instance.current_state)
	if GameManager.instance and GameManager.instance.current_state == GameManager.GameState.PLAYING:
		print("[Main] Game is in PLAYING state. Hiding menu and button.")
		menu_layer.hide()
		if start_button:
			start_button.hide()
			start_button.disabled = true
	else:
		menu_layer.show()
		if start_button:
			start_button.show()
			start_button.disabled = false

	# GameManagerのインスタンスを初期化
	if GameManager.instance == null:
		var game_manager_node = GameManager.new()
		add_child(game_manager_node)

	# シグナル接続
	dialog_system.dialog_finished.connect(_on_dialog_finished)
	scenario_manager.scenario_command_executed.connect(_on_scenario_command)
	if chapter_title:
		chapter_title.title_finished.connect(_on_chapter_title_finished)
	
	# 初期状態の設定
	dialog_system.hide()
	if chapter_title:
		chapter_title.hide()

	# GameManagerの状態がPLAYINGの場合のみシナリオを開始
	if GameManager.instance and GameManager.instance.current_state == GameManager.GameState.PLAYING:
		start_game()

func _on_start_button_pressed():
	# メニューとボタンを非表示にしてゲーム開始
	menu_layer.hide()
	if start_button:
		start_button.hide()
		start_button.disabled = true
	start_game()

func start_game():
	# BGMを再生（ロードしてAudioStreamを渡すか、play_bgm_from_pathを使う）
	print("[Main] start_game() called. GameManager.instance:", GameManager.instance)
	if GameManager.instance:
		print("[Main] Calling play_bgm_from_path for detective_office_daily.wav")
		GameManager.instance.play_bgm_from_path("res://assets/audio/bgm/detective_office_daily.wav", 1.0, true)
	else:
		printerr("[Main] GameManager.instance is null in start_game!")
	print("[Main] Starting scenario: prologue")
	scenario_manager.start_scenario("prologue")

func _on_scenario_command(command: Dictionary):
	match command.type:
		"show_chapter_title":
			# 章タイトルを表示
			var jp_text: String = command.get("japanese_title", "")
			var en_text: String = command.get("english_title", "")
			var duration: float = command.get("duration", 3.0)
			if chapter_title:
				chapter_title.show_chapter_title(jp_text, en_text, duration)
			else:
				scenario_manager.advance_scenario()
		
		"dialog":
			# ダイアログを表示
			var dialog_data = [{
				"speaker": command.speaker,
				"text": command.text
			}]
			dialog_system.start_dialog(dialog_data)
			# ダイアログ表示後にシナリオを進める（_on_dialog_finishedシグナルで処理されるため、ここでは何もしない）

		"narration":
			# ナレーションを表示
			var dialog_data = [{
				"speaker": "ナレーション",
				"text": command.text
			}]
			dialog_system.start_dialog(dialog_data)
			# ナレーション表示後にシナリオを進める（_on_dialog_finishedシグナルで処理されるため、ここでは何もしない）

		"show_character":
			# キャラクターを表示
			var char_position = get_character_position(command.position)
			character_manager.show_character(
				command.character,
				char_position,
				command.get("expression", "normal")
			)
			scenario_manager.advance_scenario()

		"change_expression":
			# 表情を変更
			character_manager.change_expression(
				command.character, 
				command.expression
			)
			scenario_manager.advance_scenario()

		"hide_character":
			# キャラクターを非表示
			character_manager.hide_character(command.character)
			scenario_manager.advance_scenario()

		"hide_all_characters":
			# 全キャラクターを非表示
			character_manager.hide_all_characters()
			scenario_manager.advance_scenario()

		"play_bgm":
			# BGMを再生
			var stream := load(command.path) as AudioStream
			if stream:
				var volume_linear: float = clamp(command.get("volume", 1.0), 0.0, 1.0)
				GameManager.instance.play_bgm(stream, linear_to_db(volume_linear), command.get("loop", true))
			else:
				push_warning("Scenario BGM not found: %s" % command.path)
			scenario_manager.advance_scenario()

		"stop_bgm":
			# BGMを停止
			GameManager.instance.stop_bgm()
			scenario_manager.advance_scenario()

func get_character_position(position_string: String):
	match position_string:
		"left":
			return character_manager.Position.LEFT
		"center":
			return character_manager.Position.CENTER
		"right":
			return character_manager.Position.RIGHT
		"far_left":
			return character_manager.Position.FAR_LEFT
		"far_right":
			return character_manager.Position.FAR_RIGHT
		_:
			return character_manager.Position.CENTER

func _on_dialog_finished():
	# ダイアログ終了後、次のシナリオコマンドを実行
	if scenario_manager.has_next_command():
		scenario_manager.advance_scenario()
	else:
		print("Scenario finished. Quitting game.")
		get_tree().quit()

func _on_chapter_title_finished():
	# 章タイトル表示終了後、次のシナリオコマンドを実行
	if scenario_manager.has_next_command():
		scenario_manager.advance_scenario()

func _input(event):
	# ESCキーでメニュー表示切り替え
	if event.is_action_pressed("ui_cancel"):
		if GameManager.instance.current_state == GameManager.GameState.DIALOG:
			return  # ダイアログ中はメニューを開かない
		menu_layer.visible = !menu_layer.visible
