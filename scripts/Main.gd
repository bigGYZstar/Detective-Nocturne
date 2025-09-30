extends Control

# メインシーンコントローラー
@onready var dialog_system: DialogSystem = $UILayer/DialogSystem
@onready var character_manager: CharacterManager = $CharacterManager
@onready var scenario_manager: ScenarioManager = $ScenarioManager
@onready var start_button: Button = $MenuLayer/StartButton
@onready var menu_layer: CanvasLayer = $MenuLayer

# 現在のダイアログデータ
var current_dialog_data: Array = []

func _ready():
	# シグナル接続
	dialog_system.dialog_finished.connect(_on_dialog_finished)
	scenario_manager.scenario_command_executed.connect(_on_scenario_command)
	
	# 初期状態の設定
	dialog_system.hide()

func _on_start_button_pressed():
	# メニューを非表示にしてゲーム開始
	menu_layer.hide()
	start_game()

func start_game():
	# 序章シナリオを開始
	scenario_manager.start_scenario("prologue")

func _on_scenario_command(command: Dictionary):
        var command_type = command.get("type", "")
        match command_type:
                "dialog":
                        # ダイアログを表示
                        var dialog_data = [{
                                "speaker": command.get("speaker", ""),
                                "text": command.get("text", "")
                        }]
                        dialog_system.start_dialog(dialog_data)

                "narration":
                        # ナレーションを表示
                        var dialog_data = [{
                                "speaker": "ナレーション",
                                "text": command.get("text", "")
                        }]
                        dialog_system.start_dialog(dialog_data)

                "show_character":
                        # キャラクターを表示
                        var position = get_character_position(command.get("position", ""))
                        character_manager.show_character(
                                command.get("character", ""),
                                position,
                                command.get("expression", "normal")
                        )
                        # 次のコマンドを実行
                        scenario_manager.advance_scenario()

                "change_expression":
                        # 表情を変更
                        character_manager.change_expression(
                                command.get("character", ""),
                                command.get("expression", "normal")
                        )
                        # 次のコマンドを実行
                        scenario_manager.advance_scenario()

                "hide_character":
                        # キャラクターを非表示
                        character_manager.hide_character(command.get("character", ""))
                        # 次のコマンドを実行
                        scenario_manager.advance_scenario()

                "hide_all_characters":
			# 全キャラクターを非表示
			character_manager.hide_all_characters()
			# 次のコマンドを実行
			scenario_manager.advance_scenario()

func get_character_position(position_string: String) -> CharacterManager.Position:
	match position_string:
		"left":
			return CharacterManager.Position.LEFT
		"center":
			return CharacterManager.Position.CENTER
		"right":
			return CharacterManager.Position.RIGHT
		"far_left":
			return CharacterManager.Position.FAR_LEFT
		"far_right":
			return CharacterManager.Position.FAR_RIGHT
		_:
			return CharacterManager.Position.CENTER

func _on_dialog_finished():
	# ダイアログ終了後、次のシナリオコマンドを実行
	scenario_manager.advance_scenario()

func _input(event):
	# ESCキーでメニュー表示切り替え
	if event.is_action_pressed("ui_cancel"):
		if GameManager.instance.current_state == GameManager.GameState.DIALOG:
			return  # ダイアログ中はメニューを開かない
		menu_layer.visible = !menu_layer.visible
