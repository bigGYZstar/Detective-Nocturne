extends Control

# How to test:
# - Toggle `bypass_typewriter` below to true for immediate text; ensure narration still shows.
# - Run the intro and watch the output for `measure:` logs or `fallback_full_text` warnings; in all cases text must stay visible.

class_name DialogSystem

@onready var dialog_box: NinePatchRect = $DialogBox
@onready var character_name: Label = $DialogBox/CharacterName
@onready var dialog_text: RichTextLabel = $DialogBox/DialogText
@onready var next_indicator: Label = $DialogBox/NextIndicator

signal dialog_finished
signal choice_selected(choice_index: int)

func _on_choice_button_pressed(index: int) -> void:
	choice_selected.emit(index)

const DEFAULT_SPEAKER := "\u30ca\u30ec\u30fc\u30b7\u30e7\u30f3"
const MAX_SETUP_RETRIES := 5
const RETRY_DELAY_SEC := 0.05
const TYPING_MIN_DURATION := 0.01

@export var bypass_typewriter := false

var current_dialog: Array = []
var current_index: int = 0
var is_typing: bool = false
var typing_speed: float = 0.05

var character_colors: Dictionary = {
	"\u307f\u305a\u304d": Color.CYAN,
	"\u3055\u304a\u308a": Color.LIGHT_PINK,
	"\u308b\u308a": Color.LIGHT_BLUE,
	"\u305f\u306a\u304b": Color.ORANGE,
	"\u306f\u305b\u304c\u308f": Color.YELLOW,
	"\u3044\u3061\u3058\u3087\u3046\u307e\u3055\u3080\u306d": Color.RED,
	DEFAULT_SPEAKER: Color.WHITE,
}

var _typing_tween: Tween = null
var _visible_character_target: int = 0
var _auto_timer: Timer = null

func _ready() -> void:
	hide()
	next_indicator.hide()
	_ensure_topmost()
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	dialog_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dialog_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dialog_text.bbcode_enabled = true
	dialog_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialog_text.fit_content = false
	dialog_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dialog_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dialog_text.custom_minimum_size.y = max(dialog_text.custom_minimum_size.y, 24.0)
	dialog_text.visible_characters = -1

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_accept"):
		if is_typing:
			complete_typing()
		else:
			advance_dialog()
		get_viewport().set_input_as_handled()

func start_dialog(dialog_data: Array) -> void:
	current_dialog = dialog_data
	current_index = 0
	show()
	_set_game_state(GameManager.GameState.DIALOG)
	display_current_dialog()

func display_current_dialog() -> void:
	if current_index >= current_dialog.size():
		end_dialog()
		return

	var dialog_entry: Dictionary = current_dialog[current_index]
	var speaker: String = dialog_entry.get("speaker", DEFAULT_SPEAKER)
	var text: String = dialog_entry.get("text", "")

	character_name.text = speaker
	character_name.modulate = character_colors.get(speaker, Color.WHITE)

	start_typing(text)

func start_typing(text: String) -> void:
	_cancel_auto_timer()
	_stop_typing_tween()

	is_typing = true
	next_indicator.hide()

	var should_type := await show_line(text)
	if not is_inside_tree() or not is_typing:
		return
	if not should_type or _visible_character_target <= 0:
		_finish_typing()
		return

	_begin_typing_animation()

func complete_typing() -> void:
	if not is_typing:
		return
	_stop_typing_tween()
	dialog_text.visible_characters = -1
	_finish_typing()

func advance_dialog() -> void:
	_cancel_auto_timer()
	if is_typing:
		complete_typing()
		return

	current_index += 1
	if current_index < current_dialog.size():
		display_current_dialog()
	else:
		end_dialog()

func end_dialog() -> void:
	_cancel_auto_timer()
	_stop_typing_tween()
	is_typing = false
	hide()
	_set_game_state(GameManager.GameState.PLAYING)
	dialog_finished.emit()

func show_choices(_choices: Array) -> void:
	# Placeholder until the choice UI is implemented.
	pass

func toggle_dialog_box() -> void:
	dialog_box.visible = !dialog_box.visible

func show_line(bbcode: String) -> bool:
	if not is_inside_tree():
		return false

	_ensure_topmost()
	visible = true
	modulate.a = 1.0
	self_modulate.a = 1.0
	dialog_box.visible = true
	dialog_box.modulate.a = 1.0
	dialog_box.self_modulate.a = 1.0
	dialog_text.visible = true
	dialog_text.modulate.a = 1.0
	dialog_text.self_modulate.a = 1.0
	dialog_text.bbcode_enabled = true
	dialog_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialog_text.fit_content = false
	dialog_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dialog_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dialog_text.custom_minimum_size.y = max(dialog_text.custom_minimum_size.y, 24.0)
	dialog_text.visible_characters = 0

	_visible_character_target = 0

	if bypass_typewriter:
		dialog_text.call_deferred("set", "text", bbcode)
		await _await_frames(2)
		dialog_text.visible_characters = -1
		print("[DialogSystem] bypass_typewriter=true -> full text")
		print_debug_info("bypass")
		return false

	dialog_text.call_deferred("set", "text", bbcode)

	for attempt in range(MAX_SETUP_RETRIES):
		await _await_frames(2)
		if not is_inside_tree():
			return false
		var total := dialog_text.get_total_character_count()
		var size := dialog_text.size
		print("[DialogSystem] measure: attempt=%d total=%d size=%s" % [attempt + 1, total, str(size)])
		if total > 0:
			_visible_character_target = total
			return true
		if attempt < MAX_SETUP_RETRIES - 1:
			await get_tree().create_timer(RETRY_DELAY_SEC).timeout

	dialog_text.visible_characters = -1
	print("[DialogSystem] fallback_full_text: attempts=%d total=0 size=%s" % [MAX_SETUP_RETRIES, str(dialog_text.size)])
	printerr("[DialogSystem] Typing aborted: total chars = 0 -> fallback to full text")
	print_debug_info("fallback")
	_visible_character_target = 0
	return false

func _begin_typing_animation() -> void:
	if not is_typing:
		return

	var total := _visible_character_target
	if total <= 0:
		printerr("[DialogSystem] Typing aborted: total chars <= 0 -> finishing immediately")
		_finish_typing()
		return

	dialog_text.visible_characters = 0
	var duration := _calculate_typing_duration(total)
	_typing_tween = create_tween()
	_typing_tween.tween_property(dialog_text, "visible_characters", total, duration)
	_typing_tween.finished.connect(_on_typing_tween_finished)

func _on_typing_tween_finished() -> void:
	_typing_tween = null
	dialog_text.visible_characters = -1
	_finish_typing()

func _finish_typing() -> void:
	if not is_typing:
		return

	is_typing = false
	dialog_text.visible_characters = -1
	next_indicator.show()

	if _should_auto_advance():
		_start_auto_timer()

func _calculate_typing_duration(char_count: int) -> float:
	var speed_scale := 1.0
	var manager := GameManager.instance
	if manager != null and manager.settings.has("text_speed"):
		speed_scale = max(float(manager.settings.text_speed), 0.01)
	return max(char_count * typing_speed / speed_scale, TYPING_MIN_DURATION)

func _stop_typing_tween() -> void:
	if _typing_tween != null:
		_typing_tween.kill()
		_typing_tween = null

func _should_auto_advance() -> bool:
	var manager := GameManager.instance
	if manager == null:
		return false
	if manager.settings.get("auto_mode", false):
		return true
	return manager.get_flag("auto_advance_dialog")

func _start_auto_timer() -> void:
	_cancel_auto_timer()

	var wait_time := _auto_wait_time()
	if wait_time <= 0.0:
		if visible and not is_typing:
			advance_dialog()
		return

	_auto_timer = Timer.new()
	_auto_timer.one_shot = true
	_auto_timer.wait_time = wait_time
	add_child(_auto_timer)
	_auto_timer.timeout.connect(_on_auto_timer_timeout)
	_auto_timer.start()

func _cancel_auto_timer() -> void:
	if _auto_timer != null:
		_auto_timer.stop()
		_auto_timer.queue_free()
		_auto_timer = null

func _on_auto_timer_timeout() -> void:
	if _auto_timer != null:
		_auto_timer.queue_free()
		_auto_timer = null

	if visible and not is_typing:
		advance_dialog()

func _auto_wait_time() -> float:
	var manager := GameManager.instance
	if manager != null and manager.settings.has("auto_speed"):
		return max(float(manager.settings.auto_speed), 0.0)
	return 0.75

func _set_game_state(state: int) -> void:
	var manager := GameManager.instance
	if manager != null:
		manager.change_state(state)

func _await_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().process_frame

func _ensure_topmost() -> void:
	z_index = max(z_index, 1000)
	dialog_box.z_index = 1000
	dialog_box.move_to_front()
	var canvas_layer := get_parent()
	if canvas_layer is CanvasLayer:
		canvas_layer.layer = max(canvas_layer.layer, 100)

func print_debug_info(tag: String) -> void:
	var parent_ctrl := dialog_text.get_parent()
	var parent_size := Vector2.ZERO
	var parent_flags_h := 0
	var parent_flags_v := 0
	if parent_ctrl is Control:
		parent_size = parent_ctrl.size
		parent_flags_h = parent_ctrl.size_flags_horizontal
		parent_flags_v = parent_ctrl.size_flags_vertical
	var canvas_layer := get_parent()
	var layer_value := 0
	if canvas_layer is CanvasLayer:
		layer_value = canvas_layer.layer
	var parts := PackedStringArray()
	parts.append("[DialogSystem] %s" % tag)
	parts.append("visible=%s" % str(visible))
	parts.append("mod_a=%.2f self_mod_a=%.2f" % [modulate.a, self_modulate.a])
	parts.append("total_chars=%d paragraphs=%d" % [dialog_text.get_total_character_count(), dialog_text.get_paragraph_count()])
	parts.append("size=%s min=%s custom_min=%s" % [str(dialog_text.size), str(dialog_text.get_minimum_size()), str(dialog_text.custom_minimum_size)])
	parts.append("autowrap=%d fit_content=%s flags_h=%d flags_v=%d" % [dialog_text.autowrap_mode, str(dialog_text.fit_content), dialog_text.size_flags_horizontal, dialog_text.size_flags_vertical])
	parts.append("parent_size=%s parent_flags_h=%d parent_flags_v=%d" % [str(parent_size), parent_flags_h, parent_flags_v])
	parts.append("layer=%d z_index=%d inside_tree=%s" % [layer_value, z_index, str(is_inside_tree())])
	print(" | ".join(parts))
