extends Control

# 設定システム
class_name SettingsSystem

@onready var master_volume_slider: HSlider = $VBoxContainer/MasterVolumeContainer/MasterVolumeSlider
@onready var bgm_volume_slider: HSlider = $VBoxContainer/BGMVolumeContainer/BGMVolumeSlider
@onready var se_volume_slider: HSlider = $VBoxContainer/SEVolumeContainer/SEVolumeSlider
@onready var text_speed_slider: HSlider = $VBoxContainer/TextSpeedContainer/TextSpeedSlider
@onready var auto_speed_slider: HSlider = $VBoxContainer/AutoSpeedContainer/AutoSpeedSlider
@onready var fullscreen_button: CheckButton = $VBoxContainer/FullscreenContainer/FullscreenButton
@onready var close_button: Button = $VBoxContainer/CloseButton

const SETTINGS_FILE_PATH = "user://settings.dat"

signal settings_changed

func _ready():
	# シグナル接続
	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	bgm_volume_slider.value_changed.connect(_on_bgm_volume_changed)
	se_volume_slider.value_changed.connect(_on_se_volume_changed)
	text_speed_slider.value_changed.connect(_on_text_speed_changed)
	auto_speed_slider.value_changed.connect(_on_auto_speed_changed)
	fullscreen_button.toggled.connect(_on_fullscreen_toggled)
	close_button.pressed.connect(_on_close_button_pressed)
	
	# 設定を読み込み
	load_settings()
	update_ui()
	
	# 初期状態では非表示
	hide()

# 設定UIを更新
func update_ui():
        var settings = GameManager.instance.settings
        var master_volume = settings.get("master_volume", 1.0)
        var bgm_volume = settings.get("bgm_volume", 0.8)
        var se_volume = settings.get("se_volume", 0.8)
        var text_speed = settings.get("text_speed", 1.0)
        var auto_speed = settings.get("auto_speed", 2.0)
        var fullscreen = settings.get("fullscreen", false)

        master_volume_slider.value = master_volume * 100
        bgm_volume_slider.value = bgm_volume * 100
        se_volume_slider.value = se_volume * 100
        text_speed_slider.value = text_speed * 100
        auto_speed_slider.value = auto_speed * 50
        fullscreen_button.button_pressed = fullscreen

# マスター音量変更
func _on_master_volume_changed(value: float):
        GameManager.instance.settings["master_volume"] = value / 100.0
        AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value / 100.0))
        settings_changed.emit()

# BGM音量変更
func _on_bgm_volume_changed(value: float):
        GameManager.instance.settings["bgm_volume"] = value / 100.0
	# BGMバスが存在する場合の処理
	var bgm_bus_index = AudioServer.get_bus_index("BGM")
	if bgm_bus_index != -1:
		AudioServer.set_bus_volume_db(bgm_bus_index, linear_to_db(value / 100.0))
	settings_changed.emit()

# SE音量変更
func _on_se_volume_changed(value: float):
        GameManager.instance.settings["se_volume"] = value / 100.0
	# SEバスが存在する場合の処理
	var se_bus_index = AudioServer.get_bus_index("SE")
	if se_bus_index != -1:
		AudioServer.set_bus_volume_db(se_bus_index, linear_to_db(value / 100.0))
	settings_changed.emit()

# テキスト速度変更
func _on_text_speed_changed(value: float):
        GameManager.instance.settings["text_speed"] = value / 100.0
        settings_changed.emit()

# オート速度変更
func _on_auto_speed_changed(value: float):
        GameManager.instance.settings["auto_speed"] = value / 50.0
        settings_changed.emit()

# フルスクリーン切り替え
func _on_fullscreen_toggled(pressed: bool):
        GameManager.instance.settings["fullscreen"] = pressed
	
	if pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	settings_changed.emit()

# 閉じるボタン
func _on_close_button_pressed():
	save_settings()
	hide()

# 設定を保存
func save_settings():
	var file = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(GameManager.instance.settings)
		file.store_string(json_string)
		file.close()
		print("Settings saved")

# 設定を読み込み
func load_settings():
	if not FileAccess.file_exists(SETTINGS_FILE_PATH):
		return
	
	var file = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var loaded_settings = json.data
			for key in loaded_settings:
				GameManager.instance.settings[key] = loaded_settings[key]
			
			# 設定を適用
			GameManager.instance.apply_settings()
			print("Settings loaded")

# 設定画面を表示
func show_settings():
	update_ui()
	show()

# デフォルト設定に戻す
func reset_to_defaults():
	GameManager.instance.settings = {
		"master_volume": 1.0,
		"bgm_volume": 0.8,
		"se_volume": 0.8,
		"voice_volume": 0.8,
		"text_speed": 1.0,
		"auto_speed": 2.0,
		"fullscreen": false
	}
	
	GameManager.instance.apply_settings()
	update_ui()
	settings_changed.emit()
