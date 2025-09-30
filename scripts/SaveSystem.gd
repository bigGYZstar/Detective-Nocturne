extends Node

# セーブ・ロードシステム
class_name SaveSystem

const SAVE_FILE_PATH = "user://save_data_%d.dat"
const MAX_SAVE_SLOTS = 10

signal save_completed(slot: int)
signal load_completed(slot: int)
signal save_failed(slot: int, error: String)
signal load_failed(slot: int, error: String)

# セーブデータを保存
func save_game(slot: int) -> bool:
	if slot < 0 or slot >= MAX_SAVE_SLOTS:
		save_failed.emit(slot, "Invalid save slot")
		return false
	
	var save_data = GameManager.instance.create_save_data()
	var file_path = SAVE_FILE_PATH % slot
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		save_failed.emit(slot, "Could not open file for writing")
		return false
	
	var json_string = JSON.stringify(save_data)
	file.store_string(json_string)
	file.close()
	
	save_completed.emit(slot)
	print("Game saved to slot ", slot)
	return true

# セーブデータを読み込み
func load_game(slot: int) -> bool:
	if slot < 0 or slot >= MAX_SAVE_SLOTS:
		load_failed.emit(slot, "Invalid save slot")
		return false
	
	var file_path = SAVE_FILE_PATH % slot
	
	if not FileAccess.file_exists(file_path):
		load_failed.emit(slot, "Save file does not exist")
		return false
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		load_failed.emit(slot, "Could not open file for reading")
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		load_failed.emit(slot, "Invalid save data format")
		return false
	
	var save_data = json.data
	GameManager.instance.load_save_data(save_data)
	
	load_completed.emit(slot)
	print("Game loaded from slot ", slot)
	return true

# セーブファイルが存在するかチェック
func save_exists(slot: int) -> bool:
	if slot < 0 or slot >= MAX_SAVE_SLOTS:
		return false
	
	var file_path = SAVE_FILE_PATH % slot
	return FileAccess.file_exists(file_path)

# セーブファイルの情報を取得
func get_save_info(slot: int) -> Dictionary:
	if not save_exists(slot):
		return {}
	
	var file_path = SAVE_FILE_PATH % slot
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file == null:
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		return {}
	
	var save_data = json.data
	return {
		"chapter": save_data.get("chapter", 0),
		"scene": save_data.get("scene", 0),
		"timestamp": save_data.get("timestamp", 0)
	}

# セーブファイルを削除
func delete_save(slot: int) -> bool:
	if slot < 0 or slot >= MAX_SAVE_SLOTS:
		return false
	
	var file_path = SAVE_FILE_PATH % slot
	
	if not FileAccess.file_exists(file_path):
		return false
	
	var dir = DirAccess.open("user://")
	if dir:
		var result = dir.remove(file_path.get_file())
		return result == OK
	
	return false

# 全セーブスロットの情報を取得
func get_all_save_info() -> Array:
	var save_info_list = []

	for i in range(MAX_SAVE_SLOTS):
		var info = get_save_info(i)
		if info.is_empty():
			save_info_list.append({
				"slot": i,
				"exists": false,
				"chapter": 0,
				"scene": 0,
				"timestamp": 0,
				"formatted_time": "空きスロット"
			})
		else:
			var timestamp = info.get("timestamp", 0)
			var datetime = Time.get_datetime_dict_from_unix_time(timestamp)
			var formatted_time = "%04d/%02d/%02d %02d:%02d" % [
				datetime.get("year", 0), datetime.get("month", 0), datetime.get("day", 0),
				datetime.get("hour", 0), datetime.get("minute", 0)
			]

			save_info_list.append({
				"slot": i,
				"exists": true,
				"chapter": info.get("chapter", 0),
				"scene": info.get("scene", 0),
				"timestamp": timestamp,
				"formatted_time": formatted_time
			})

	return save_info_list
