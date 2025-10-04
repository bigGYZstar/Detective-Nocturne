extends Node

var failures: Array[String] = []

func _ready() -> void:
	await get_tree().process_frame
	await _run_tests()
	if failures.is_empty():
		print("[CI] All tests passed")
		get_tree().quit(0)
	else:
		for message in failures:
			printerr(message)
		get_tree().quit(1)

func _run_tests() -> void:
	await _test_transparent_png()
	await _test_bgm_playback()
	await _test_dialog_text_visible()

func _test_transparent_png() -> void:
	var image_path := "res://assets/characters/saori_smile_transparent.png"
	var image := Image.load_from_file(image_path)
	if image == null:
		_fail("[CI][FAIL] Transparency test: failed to load image at %s" % image_path)
		return
	var has_alpha := image.detect_alpha()
	var found_transparency := false
	if has_alpha:
		for y in range(image.get_height()):
			for x in range(image.get_width()):
				if image.get_pixel(x, y).a < 0.99:
					found_transparency = true
					break
			if found_transparency:
				break
	if has_alpha and found_transparency:
		print("[CI] Transparency test passed: alpha preserved for %s" % image_path)
	else:
		_fail("[CI][FAIL] Transparency test: alpha channel missing or fully opaque for %s" % image_path)

func _test_bgm_playback() -> void:
	var bgm_path := "res://assets/audio/bgm/bgm_title_screen.wav"
	var stream := load(bgm_path)
	if stream == null:
		_fail("[CI][FAIL] BGM test: failed to load stream at %s" % bgm_path)
		return
	var player := AudioStreamPlayer.new()
	add_child(player)
	player.stream = stream
	player.play()
	await get_tree().process_frame
	if player.playing:
		print("[CI] BGM playback test passed: %s" % bgm_path)
	else:
		_fail("[CI][FAIL] BGM test: AudioStreamPlayer failed to start playback for %s" % bgm_path)
	player.stop()
	player.queue_free()

func _test_dialog_text_visible() -> void:
	var scene := load("res://scenes/Main.tscn")
	if scene == null:
		_fail("[CI][FAIL] Dialog test: failed to load Main.tscn")
		return
	var main_instance := scene.instantiate()
	get_tree().root.add_child(main_instance)
	await get_tree().process_frame
	var dialog_system: DialogSystem = main_instance.get_node("UILayer/DialogSystem")
	dialog_system.bypass_typewriter = true
	dialog_system.start_dialog([
		{
			"speaker": "Test",
			"text": "[b]CI dialog visibility check[/b]"
		}
	])
	await get_tree().process_frame
	await get_tree().process_frame
	var total := dialog_system.dialog_text.get_total_character_count()
	var visible_chars := dialog_system.dialog_text.visible_characters
	var has_text := not dialog_system.dialog_text.bbcode_text.strip_edges().is_empty()
	if total > 0 and visible_chars == -1 and has_text:
		print("[CI] Dialog text visibility test passed")
	else:
		_fail("[CI][FAIL] Dialog test: text not visible (total=%d, visible=%d, has_text=%s)" % [total, visible_chars, str(has_text)])
	main_instance.queue_free()
	await get_tree().process_frame

func _fail(message: String) -> void:
	failures.append(message)
