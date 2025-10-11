extends Control

class_name ChapterTitle

signal title_finished

@onready var japanese_title: Label = $CenterContainer/TitleContainer/JapaneseTitle
@onready var english_title: Label = $CenterContainer/TitleContainer/EnglishTitle
@onready var separator: Panel = $CenterContainer/TitleContainer/Separator
@onready var background: ColorRect = $Background
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var display_duration: float = 3.0
var fade_in_duration: float = 1.0
var fade_out_duration: float = 1.0

func _ready() -> void:
	hide()
	modulate.a = 0.0

func show_chapter_title(jp_text: String, en_text: String, duration: float = 3.0) -> void:
	japanese_title.text = jp_text
	english_title.text = en_text
	display_duration = duration
	
	show()
	_play_animation()

func _play_animation() -> void:
	# フェードイン
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_in_duration)
	
	# 表示時間待機
	await get_tree().create_timer(display_duration).timeout
	
	# フェードアウト
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(self, "modulate:a", 0.0, fade_out_duration)
	fade_out_tween.finished.connect(_on_animation_finished)

func _on_animation_finished() -> void:
	hide()
	title_finished.emit()

func skip_animation() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.finished.connect(_on_animation_finished)

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_accept"):
		skip_animation()
		get_viewport().set_input_as_handled()

