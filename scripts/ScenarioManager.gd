extends Node

class_name ScenarioManager

signal scenario_command_executed(command: Dictionary)
signal scenario_loaded(chapter_id: String)

var scenario_data: Dictionary = {}
var asset_manifest: Dictionary = {}
var current_scenario_commands: Array = []
var current_command_index: int = 0
var current_chapter_id: String = ""

# 既読管理用のセット
var read_commands: Dictionary = {}

func _ready():
	load_asset_manifest()
	load_all_scenarios()

func load_asset_manifest():
	var file = FileAccess.open("res://data/assets/manifest.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		asset_manifest = JSON.parse_string(content)
		file.close()
		if asset_manifest == null:
			printerr("Error parsing manifest.json")
	else:
		printerr("Could not open manifest.json")

func load_all_scenarios():
	var dir = DirAccess.open("res://data/scenarios/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".json"):
				var chapter_id = file_name.replace(".json", "")
				var file_path = "res://data/scenarios/" + file_name
				var file = FileAccess.open(file_path, FileAccess.READ)
				if file:
					var content = file.get_as_text()
					var parsed_scenario = JSON.parse_string(content)
					file.close()
					if parsed_scenario == null:
						printerr("Error parsing scenario file: " + file_name)
					else:
						scenario_data[chapter_id] = parsed_scenario
						print("Loaded scenario: " + chapter_id)
				else:
					printerr("Could not open scenario file: " + file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		printerr("Could not open directory: res://data/scenarios/")

func start_scenario(chapter_id: String, start_command_id: String = ""):
	if not scenario_data.has(chapter_id):
		printerr("Scenario chapter not found: " + chapter_id)
		return

	current_chapter_id = chapter_id
	current_scenario_commands = scenario_data[chapter_id]
	current_command_index = 0

	if start_command_id != "":
		var found_index = -1
		for i in range(current_scenario_commands.size()):
			if current_scenario_commands[i].has("id") and current_scenario_commands[i]["id"] == start_command_id:
				found_index = i
				break
		if found_index != -1:
			current_command_index = found_index
		else:
			printerr("Start command ID not found in scenario: " + start_command_id)
			return

	scenario_loaded.emit(chapter_id)
	execute_current_command()

func execute_current_command():
	if current_command_index >= current_scenario_commands.size():
		print("Scenario finished for chapter: " + current_chapter_id)
		return

	var command = current_scenario_commands[current_command_index]
	
	# 既読としてマーク
	if command.has("id"):
		mark_command_as_read(current_chapter_id, command["id"])

	scenario_command_executed.emit(command)

func advance_scenario(skip_read: bool = false):
	current_command_index += 1
	while skip_read and current_command_index < current_scenario_commands.size():
		var command = current_scenario_commands[current_command_index]
		if command.has("id") and is_command_read(current_chapter_id, command["id"]):
			current_command_index += 1
		else:
			break

	execute_current_command()

func has_next_command() -> bool:
	return current_command_index < current_scenario_commands.size()

func get_asset_path(asset_type: String, asset_key: String, sub_key: String = "") -> String:
	if asset_manifest.has(asset_type):
		if sub_key != "":
			if asset_manifest[asset_type].has(asset_key) and asset_manifest[asset_type][asset_key].has(sub_key):
				return asset_manifest[asset_type][asset_key][sub_key]
			else:
				printerr("Asset sub_key not found in manifest: " + asset_type + "." + asset_key + "." + sub_key)
		elif asset_manifest[asset_type].has(asset_key):
			return asset_manifest[asset_type][asset_key]
		else:
			printerr("Asset key not found in manifest: " + asset_type + "." + asset_key)
	else:
		printerr("Asset type not found in manifest: " + asset_type)
	return ""

# セーブ/ロード機能のための状態取得
func get_current_state() -> Dictionary:
	return {
		"chapter_id": current_chapter_id,
		"command_id": current_scenario_commands[current_command_index]["id"] if current_scenario_commands.size() > 0 and current_command_index < current_scenario_commands.size() and current_scenario_commands[current_command_index].has("id") else "",
		"read_commands": read_commands
	}

# セーブ状態からの復元
func load_state(state: Dictionary):
	current_chapter_id = state.get("chapter_id", "")
	read_commands = state.get("read_commands", {})
	if current_chapter_id != "":
		start_scenario(current_chapter_id, state.get("command_id", ""))

# 既読管理
func mark_command_as_read(chapter_id: String, command_id: String):
	if not read_commands.has(chapter_id):
		read_commands[chapter_id] = {}
	read_commands[chapter_id][command_id] = true

func is_command_read(chapter_id: String, command_id: String) -> bool:
	return read_commands.has(chapter_id) and read_commands[chapter_id].has(command_id) and read_commands[chapter_id][command_id]

# バリデーション機能 (簡易版)
func validate_scenario_data():
	var errors = []
	for chapter_id in scenario_data:
		var chapter_commands = scenario_data[chapter_id]
		var command_ids = {}
		for i in range(chapter_commands.size()):
			var command = chapter_commands[i]
			if not command.has("id"):
				errors.append("Chapter '%s', Command index %d: Missing 'id' field." % [chapter_id, i])
				continue
			var cmd_id = command["id"]
			if command_ids.has(cmd_id):
				errors.append("Chapter '%s', Command ID '%s': Duplicate ID found." % [chapter_id, cmd_id])
			command_ids[cmd_id] = true

			# アセット参照のチェック (簡易版)
			if command.has("character"):
				if not asset_manifest.has("characters") or not asset_manifest["characters"].has(command["character"]):
					errors.append("Chapter '%s', Command ID '%s': Undefined character asset '%s'." % [chapter_id, cmd_id, command["character"]])
			if command.has("background"):
				if not asset_manifest.has("backgrounds") or not asset_manifest["backgrounds"].has(command["background"]):
					errors.append("Chapter '%s', Command ID '%s': Undefined background asset '%s'." % [chapter_id, cmd_id, command["background"]])
			
			# ジャンプ先のチェック (もしjumpコマンドがあれば)
			if command.get("type") == "jump":
				var target_chapter = command.get("target_chapter", chapter_id)
				var target_id = command.get("target_id")
				if not scenario_data.has(target_chapter):
					errors.append("Chapter '%s', Command ID '%s': Jump target chapter '%s' not found." % [chapter_id, cmd_id, target_chapter])
				elif target_id != null:
					var target_found = false
					for target_cmd in scenario_data[target_chapter]:
						if target_cmd.has("id") and target_cmd["id"] == target_id:
							target_found = true
							break
					if not target_found:
						errors.append("Chapter '%s', Command ID '%s': Jump target ID '%s' not found in chapter '%s'." % [chapter_id, cmd_id, target_id, target_chapter])

			# 翻訳キーのチェック (簡易版)
			if command.has("text") and typeof(command["text"]) == TYPE_DICTIONARY:
				if not command["text"].has("ja") and not command["text"].has("text_key"):
					errors.append("Chapter '%s', Command ID '%s': Text field missing 'ja' or 'text_key'." % [chapter_id, cmd_id])

	if errors.is_empty():
		print("Scenario data validation successful.")
	else:
		printerr("Scenario data validation failed with %d errors:" % errors.size())
		for error in errors:
			printerr("- " + error)
	return errors.is_empty()


func load_scenario_data():
	# シナリオデータはJSONファイルから自動的にロードされるため、ここでは何もしません。
	pass

