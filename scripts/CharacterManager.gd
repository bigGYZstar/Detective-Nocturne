extends Node2D

# キャラクター管理システム
class_name CharacterManager

# キャラクター表示位置
enum Position {
	LEFT,
	CENTER,
	RIGHT,
	FAR_LEFT,
	FAR_RIGHT
}

# 現在表示中のキャラクター
var active_characters: Dictionary = {}

# キャラクター画像のパス
var character_paths: Dictionary = {
	"mizuki": "res://assets/images/characters/mizuki/",
	"saori": "res://assets/images/characters/saori/",
	"ruri": "res://assets/images/characters/ruri/"
}

# 表情リスト
var expressions: Array = ["normal", "smile", "sad", "angry", "surprised"]

# 位置座標
var positions: Dictionary = {
	Position.FAR_LEFT: Vector2(200, 540),
	Position.LEFT: Vector2(480, 540),
	Position.CENTER: Vector2(960, 540),
	Position.RIGHT: Vector2(1440, 540),
	Position.FAR_RIGHT: Vector2(1720, 540)
}

signal character_animation_finished

func _ready():
	# キャラクター画像フォルダを作成
	create_character_folders()

# キャラクターを表示
func show_character(character_name: String, position: Position, expression: String = "normal"):
	# 既存のキャラクターがいる場合は削除
	if character_name in active_characters:
		hide_character(character_name)
	
	# 新しいキャラクターを作成
	var character_sprite = Sprite2D.new()
	character_sprite.name = character_name
	
	# 実際の画像ファイルを読み込み
	var texture = load_character_image(character_name, expression)
	character_sprite.texture = texture
	
	# 位置を設定
	character_sprite.position = positions[position]
	character_sprite.scale = Vector2(0.8, 0.8)  # 適度なサイズに調整
	
	# シーンに追加
	add_child(character_sprite)
	active_characters[character_name] = character_sprite
	
	# フェードイン効果
	character_sprite.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(character_sprite, "modulate:a", 1.0, 0.5)
	tween.tween_callback(func(): character_animation_finished.emit())
	await get_tree().create_timer(0.5).timeout # フェードインの完了を待つ

# キャラクターを非表示
func hide_character(character_name: String):
	if character_name in active_characters:
		var character_sprite = active_characters[character_name]
		
		# フェードアウト効果
		var tween = create_tween()
		tween.tween_property(character_sprite, "modulate:a", 0.0, 0.3)
		tween.tween_callback(func(): 
			character_sprite.queue_free()
			active_characters.erase(character_name)
			character_animation_finished.emit()
		)
	await get_tree().create_timer(0.3).timeout # フェードアウトの完了を待つ

# 表情を変更
func change_expression(character_name: String, expression: String):
	if character_name in active_characters:
		var character_sprite = active_characters[character_name]
		var texture = load_character_image(character_name, expression)
		character_sprite.texture = texture

# 全キャラクターを非表示
func hide_all_characters():
	for character_name in active_characters.keys():
		hide_character(character_name)

# 実際のキャラクター画像を読み込み
func load_character_image(character_name: String, expression: String = "normal") -> Texture2D:
	var image_path = "res://assets/characters/" + character_name + "_" + expression + ".png"
	
	# 実際の画像ファイルを読み込み
	if ResourceLoader.exists(image_path):
		var texture = load(image_path) as Texture2D
		if texture:
			print("Loaded character image: ", image_path)
			return texture
		else:
			print("Failed to load texture: ", image_path)
	else:
		print("Image file not found: ", image_path)
	
	# フォールバック：プレースホルダー画像を生成
	print("Using placeholder for: ", character_name, " with expression: ", expression)
	return create_placeholder_texture(character_name, expression)

# プレースホルダーテクスチャを作成
func create_placeholder_texture(character_name: String, expression: String) -> ImageTexture:
	var image = Image.create(400, 800, false, Image.FORMAT_RGB8)
	
	# キャラクターごとに色を変える
	var color: Color
	match character_name:
		"mizuki":
			color = Color.CYAN
		"saori":
			color = Color.LIGHT_PINK
		"ruri":
			color = Color.LIGHT_BLUE
		_:
			color = Color.GRAY
	
	# 表情によって明度を変える
	match expression:
		"smile":
			color = color.lightened(0.2)
		"sad":
			color = color.darkened(0.3)
		"angry":
			color = Color.RED.lerp(color, 0.5)
		"surprised":
			color = Color.YELLOW.lerp(color, 0.3)
	
	image.fill(color)
	
	# 簡単な顔を描画
	draw_simple_face(image, expression)
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

# 簡単な顔を描画
func draw_simple_face(image: Image, expression: String):
	var width = image.get_width()
	var height = image.get_height()
	
	# 目の位置
	var eye_y = height * 0.3
	var left_eye_x = width * 0.3
	var right_eye_x = width * 0.7
	
	# 口の位置
	var mouth_y = height * 0.6
	var mouth_x = width * 0.5
	
	# 目を描画
	draw_circle_on_image(image, Vector2i(left_eye_x, eye_y), 20, Color.BLACK)
	draw_circle_on_image(image, Vector2i(right_eye_x, eye_y), 20, Color.BLACK)
	
	# 表情に応じた口を描画
	match expression:
		"smile":
			draw_arc_on_image(image, Vector2i(mouth_x, mouth_y), 30, 0, PI, Color.BLACK)
		"sad":
			draw_arc_on_image(image, Vector2i(mouth_x, mouth_y + 20), 30, PI, 2*PI, Color.BLACK)
		"angry":
			draw_line_on_image(image, Vector2i(mouth_x - 30, mouth_y), Vector2i(mouth_x + 30, mouth_y), Color.BLACK)
		"surprised":
			draw_circle_on_image(image, Vector2i(mouth_x, mouth_y), 15, Color.BLACK)
		_:  # normal
			draw_line_on_image(image, Vector2i(mouth_x - 20, mouth_y), Vector2i(mouth_x + 20, mouth_y), Color.BLACK)

# 画像に円を描画
func draw_circle_on_image(image: Image, center: Vector2i, radius: int, color: Color):
	for y in range(center.y - radius, center.y + radius + 1):
		for x in range(center.x - radius, center.x + radius + 1):
			if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height():
				var distance = Vector2(x - center.x, y - center.y).length()
				if distance <= radius:
					image.set_pixel(x, y, color)

# 画像に線を描画
func draw_line_on_image(image: Image, start: Vector2i, end: Vector2i, color: Color):
	var points = get_line_points(start, end)
	for point in points:
		if point.x >= 0 and point.x < image.get_width() and point.y >= 0 and point.y < image.get_height():
			image.set_pixel(point.x, point.y, color)

# 画像に弧を描画
func draw_arc_on_image(image: Image, center: Vector2i, radius: int, start_angle: float, end_angle: float, color: Color):
	var steps = 50
	for i in range(steps + 1):
		var angle = start_angle + (end_angle - start_angle) * i / steps
		var x = center.x + cos(angle) * radius
		var y = center.y + sin(angle) * radius
		var point = Vector2i(x, y)
		if point.x >= 0 and point.x < image.get_width() and point.y >= 0 and point.y < image.get_height():
			image.set_pixel(point.x, point.y, color)

# 線の点を取得（Bresenhamアルゴリズム）
func get_line_points(start: Vector2i, end: Vector2i) -> Array:
	var points = []
	var dx = abs(end.x - start.x)
	var dy = abs(end.y - start.y)
	var sx = 1 if start.x < end.x else -1
	var sy = 1 if start.y < end.y else -1
	var err = dx - dy
	
	var x = start.x
	var y = start.y
	
	while true:
		points.append(Vector2i(x, y))
		
		if x == end.x and y == end.y:
			break
			
		var e2 = 2 * err
		if e2 > -dy:
			err -= dy
			x += sx
		if e2 < dx:
			err += dx
			y += sy
	
	return points

# キャラクター画像フォルダを作成
func create_character_folders():
	var dir = DirAccess.open("res://")
	if dir:
		for character in character_paths.keys():
			var path = character_paths[character]
			if not dir.dir_exists(path):
				dir.make_dir_recursive(path)

