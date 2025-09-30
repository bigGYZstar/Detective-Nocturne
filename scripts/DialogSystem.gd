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
var typing_full_text: String = ""
var typing_tween: Tween = null
var auto_timer: SceneTreeTimer = null

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
        _cancel_auto_timer()
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
        typing_full_text = text
        _cancel_typing_animation()
        _cancel_auto_timer()
        is_typing = true
        next_indicator.hide()
        dialog_text.text = ""

        # リッチテキストの処理
        dialog_text.append_text("")

        if text.is_empty():
                complete_typing()
                return

        var text_speed = GameManager.instance.settings.get("text_speed", 1.0)
        if text_speed <= 0:
                text_speed = 1.0

        var duration = typing_speed * text.length() / text_speed
        if duration <= 0:
                duration = 0.01

        typing_tween = create_tween()
        typing_tween.tween_method(_update_dialog_text.bind(text), 0.0, float(text.length()), duration)
        typing_tween.finished.connect(_on_typing_tween_finished)

# タイピング完了
func complete_typing():
        if not is_typing:
                return
        _cancel_typing_animation()
        is_typing = false
        dialog_text.text = typing_full_text
        next_indicator.show()
        _start_auto_timer()

# ダイアログを進める
func advance_dialog():
        _cancel_auto_timer()
        current_index += 1
        display_current_dialog()

# ダイアログ終了
func end_dialog():
        _cancel_typing_animation()
        _cancel_auto_timer()
        hide()
        GameManager.instance.change_state(GameManager.GameState.PLAYING)
        dialog_finished.emit()

# 選択肢を表示
func show_choices(_choices: Array):
	# 選択肢UIの実装（将来実装）
	pass

# ダイアログボックスの表示/非表示
func toggle_dialog_box():
        dialog_box.visible = !dialog_box.visible

func _update_dialog_text(value: float, text: String):
        if not is_typing:
                return
        var character_count = clamp(int(round(value)), 0, text.length())
        dialog_text.text = text.substr(0, character_count)

func _on_typing_tween_finished():
        typing_tween = null
        if is_typing:
                complete_typing()

func _cancel_typing_animation():
        if typing_tween != null:
                typing_tween.kill()
                typing_tween = null

func _start_auto_timer():
        if not GameManager.instance.settings.get("auto_mode", false):
                return
        var auto_speed = GameManager.instance.settings.get("auto_speed", 2.0)
        if auto_speed <= 0:
                auto_speed = 0.1
        _cancel_auto_timer()
        auto_timer = get_tree().create_timer(auto_speed)
        var timer_reference := auto_timer
        auto_timer.timeout.connect(func():
                if auto_timer != timer_reference:
                        return
                auto_timer = null
                if not is_typing and visible:
                        advance_dialog()
        )

func _cancel_auto_timer():
        if auto_timer == null:
                return
        auto_timer = null
        # Signal connections use a lambda that checks the stored reference, so simply clearing the reference cancels pending callbacks.
