extends Node

# ゲーム全体を管理するシングルトンクラス
class_name GameManager

# シングルトンインスタンス
static var instance: GameManager

# ゲーム状態
enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	DIALOG,
	LOADING
}

var current_state: GameState = GameState.MENU
var current_chapter: int = 0
var current_scene: int = 0

# キャラクター好感度
var character_affection: Dictionary = {
	"mizuki": 0,
	"saori": 0,
	"ruri": 0
}

# ゲームフラグ
var game_flags: Dictionary = {}

# 設定
var settings: Dictionary = {
	"master_volume": 1.0,
	"bgm_volume": 0.8,
	"se_volume": 0.8,
	"voice_volume": 0.8,
	"text_speed": 1.0,
	"auto_speed": 2.0,
	"fullscreen": false
}

func _ready():
	if instance == null:
		instance = self
		process_mode = Node.PROCESS_MODE_ALWAYS
		_ensure_bgm_player()
	else:
		queue_free()

# ゲーム状態の変更
func change_state(new_state: GameState):
	current_state = new_state
	print("Game state changed to: ", GameState.keys()[new_state])

# フラグの設定
func set_flag(flag_name: String, value: bool):
	game_flags[flag_name] = value
	print("Flag set: ", flag_name, " = ", value)

# フラグの取得
func get_flag(flag_name: String) -> bool:
	return game_flags.get(flag_name, false)

# 好感度の変更
func change_affection(character: String, amount: int):
	if character in character_affection:
		character_affection[character] += amount
		character_affection[character] = clamp(character_affection[character], -100, 100)
		print("Affection changed: ", character, " = ", character_affection[character])

# 好感度の取得
func get_affection(character: String) -> int:
	return character_affection.get(character, 0)

# セーブデータの作成
func create_save_data() -> Dictionary:
	return {
		"chapter": current_chapter,
		"scene": current_scene,
		"affection": character_affection.duplicate(),
		"flags": game_flags.duplicate(),
		"settings": settings.duplicate(),
		"timestamp": Time.get_unix_time_from_system()
	}

# セーブデータの読み込み
func load_save_data(save_data: Dictionary):
	current_chapter = save_data.get("chapter", 0)
	current_scene = save_data.get("scene", 0)
	character_affection = save_data.get("affection", {})
	game_flags = save_data.get("flags", {})
	settings = save_data.get("settings", settings)
	
	# 設定を適用
	apply_settings()

# 設定の適用
func apply_settings():
	# 音量設定
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(settings.master_volume))
	
	# フルスクリーン設定
	if settings.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

# 次のシーンへ進む
func advance_scene():
	current_scene += 1
	print("Advanced to scene: ", current_scene)

# 次の章へ進む
func advance_chapter():
	current_chapter += 1
	current_scene = 0
	print("Advanced to chapter: ", current_chapter)

# ゲーム終了
func quit_game():
	get_tree().quit()


# BGM管理
var bgm_player: AudioStreamPlayer = null
var bgm_offset_db: float = 0.0

func _ensure_bgm_player() -> void:
	if bgm_player == null:
		bgm_player = AudioStreamPlayer.new()
	var parent := bgm_player.get_parent()
	if parent != self:
		if parent != null:
			parent.remove_child(bgm_player)
		add_child(bgm_player)
	bgm_player.bus = _determine_bgm_bus()

func play_bgm(stream: AudioStream, volume_db: float = 0.0, _loop: bool = true) -> void:
	if stream == null:
		printerr("[GameManager] play_bgm called with null stream")
		return

	var playable := stream.duplicate() if stream.has_method("duplicate") else stream
	if playable is AudioStreamWAV:
			playable.loop_mode = AudioStreamWAV.LOOP_FORWARD if _loop else AudioStreamWAV.LOOP_DISABLED
	elif playable.has_method("set_loop"):
		playable.set_loop(_loop)

	_ensure_bgm_player()
	bgm_player.stream = playable
	bgm_offset_db = volume_db
	bgm_player.volume_db = linear_to_db(settings.bgm_volume) + bgm_offset_db
	bgm_player.play()
	print("[GameManager] Playing BGM stream")

func play_bgm_from_path(path: String, volume: float = 1.0, loop: bool = true) -> void:
	if path.is_empty():
		printerr("[GameManager] play_bgm_from_path called with empty path")
		return

	var stream := load(path) as AudioStream
	if stream == null:
		printerr("[GameManager] Failed to load BGM: %s" % path)
		return

	var clamped_volume: float = clamp(volume, 0.0, 1.0)
	play_bgm(stream, linear_to_db(clamped_volume), loop)

func stop_bgm() -> void:
	if bgm_player == null:
		return
	bgm_player.stop()
	print("BGM stopped.")

func set_bgm_volume(volume: float) -> void:
	settings.bgm_volume = volume
	_ensure_bgm_player()
	if bgm_player.stream:
		bgm_player.volume_db = linear_to_db(settings.bgm_volume) + bgm_offset_db
	print("BGM volume set to: ", volume)

func _determine_bgm_bus() -> String:
	var index := AudioServer.get_bus_index("BGM")
	return "BGM" if index != -1 else "Master"



# セーブデータのパス
const SAVE_PATH = "user://savegame.dat"

# ゲームをセーブ
func save_game() -> bool:
	var save_dict = create_save_data()
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_dict))
		file.close()
		print("Game saved successfully.")
		return true
	else:
		printerr("Failed to save game.")
		return false

# ゲームをロード
func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save game found.")
		return {}

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		var save_dict = JSON.parse_string(content)
		if save_dict:
			print("Game loaded successfully.")
			return save_dict
		else:
			printerr("Failed to parse save data.")
			return {}
	else:
		printerr("Failed to load game.")	
		return {}
