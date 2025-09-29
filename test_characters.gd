extends Node2D

# キャラクター表示テスト用スクリプト

var character_manager: CharacterManager

func _ready():
	# CharacterManagerを作成
	character_manager = CharacterManager.new()
	add_child(character_manager)
	
	# 3秒後にキャラクターを表示
	await get_tree().create_timer(1.0).timeout
	test_character_display()

func test_character_display():
	print("Testing character display...")
	
	# みずきを左に表示
	character_manager.show_character("mizuki", CharacterManager.Position.LEFT, "normal")
	
	await get_tree().create_timer(2.0).timeout
	
	# 沙織を中央に表示
	character_manager.show_character("saori", CharacterManager.Position.CENTER, "normal")
	
	await get_tree().create_timer(2.0).timeout
	
	# 瑠璃を右に表示
	character_manager.show_character("ruri", CharacterManager.Position.RIGHT, "normal")
	
	print("Character display test completed!")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		# スペースキーでキャラクターを非表示
		character_manager.hide_all_characters()
	elif event.is_action_pressed("ui_cancel"):
		# ESCキーでテスト再実行
		character_manager.hide_all_characters()
		await get_tree().create_timer(1.0).timeout
		test_character_display()
