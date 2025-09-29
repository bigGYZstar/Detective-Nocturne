extends Control

# ダイアログシステム
class_name DialogSystem

# UI要素
@onready var dialog_box: NinePatchRect = $DialogBox
@onready var character_name: Label = $DialogBox/CharacterName
@onready var dialog_text: RichTextLabel = $DialogBox/DialogText
@onready var next_indicator: Label = $DialogBox/NextIndicator

# 現在の会話データ
var current_dialog: Array = []
var current_index: int = 0
var is_typing: bool = false
var typing_speed: float = 0.05

# キャラクター色設定
var character_colors: Dictionary = {
	"みずき": Color.CYAN,
	"沙織": Color.LIGHT_PINK,
	"瑠璃": Color.LIGHT_BLUE,
	"田中": Color.ORANGE,
	"長谷川": Color.YELLOW,
	"一条正宗": Color.RED,
	"ナレーション": Color.WHITE
}

signal dialog_finished
signal choice_selected(choice_index: int)

# 選択肢が選ばれた際にシグナルを発火させるための仮の関数
func _on_choice_button_pressed(index: int):
	choice_selected.emit(index)


func _ready():
	hide()
	next_indicator.hide()

func _input(event):
	if visible and event.is_action_pressed("ui_accept"):
		if is_typing:
			# タイピング中なら即座に表示
			complete_typing()
		else:
			# 次のダイアログへ
			advance_dialog()

# ダイアログを開始
func start_dialog(dialog_data: Array):
	current_dialog = dialog_data
	current_index = 0
	show()
	GameManager.instance.change_state(GameManager.GameState.DIALOG)
	display_current_dialog()

# 現在のダイアログを表示
func display_current_dialog():
	if current_index >= current_dialog.size():
		end_dialog()
		return
	
	var dialog_entry = current_dialog[current_index]
	var speaker = dialog_entry.get("speaker", "ナレーション")
	var text = dialog_entry.get("text", "")
	
	# キャラクター名の設定
	character_name.text = speaker
	character_name.modulate = character_colors.get(speaker, Color.WHITE)
	
	# テキストのタイピング開始
	start_typing(text)

# タイピング開始
func start_typing(text: String):
	is_typing = true
	next_indicator.hide()
	dialog_text.text = ""
	
	# リッチテキストの処理
	dialog_text.append_text("")
	
	var tween = create_tween()
	var char_count = text.length()
	
	for i in range(char_count + 1):
		tween.tween_callback(func(): dialog_text.text = text.substr(0, i))
		await get_tree().create_timer(typing_speed / GameManager.instance.settings.text_speed).timeout
	
	tween.tween_callback(complete_typing)

# タイピング完了
func complete_typing():
	is_typing = false
	next_indicator.show()
	
	# 自動進行の処理
	if GameManager.instance.settings.get("auto_mode", false):
		await get_tree().create_timer(GameManager.instance.settings.auto_speed).timeout
		advance_dialog()

# ダイアログを進める
func advance_dialog():
	current_index += 1
	display_current_dialog()

# ダイアログ終了
func end_dialog():
	hide()
	GameManager.instance.change_state(GameManager.GameState.PLAYING)
	dialog_finished.emit()

# 選択肢を表示
func show_choices(choices: Array):
	# 選択肢UIの実装（将来実装）
	pass

# ダイアログボックスの表示/非表示
func toggle_dialog_box():
	dialog_box.visible = !dialog_box.visible
