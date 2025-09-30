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
        var master_volume = settings.get("master_volume", 1.0)
        AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))

        # フルスクリーン設定
        if settings.get("fullscreen", false):
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
