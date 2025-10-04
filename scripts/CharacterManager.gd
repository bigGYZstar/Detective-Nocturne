extends Node2D

class_name CharacterManager

enum Position {
	LEFT,
	CENTER,
	RIGHT,
	FAR_LEFT,
	FAR_RIGHT
}

var active_characters: Dictionary = {}

var expressions: Array = ["normal", "smile", "sad", "angry", "surprised"]

var positions: Dictionary = {
	Position.FAR_LEFT: Vector2(200, 540),
	Position.LEFT: Vector2(480, 540),
	Position.CENTER: Vector2(960, 540),
	Position.RIGHT: Vector2(1440, 540),
	Position.FAR_RIGHT: Vector2(1720, 540)
}

signal character_animation_finished

func show_character(character_name: String, position: Position, expression: String = "normal") -> void:
	if character_name in active_characters:
		hide_character(character_name)

	var sprite := Sprite2D.new()
	sprite.name = character_name

	var texture := _load_character_texture(character_name, expression)
	sprite.texture = texture
	sprite.position = positions[position]
	sprite.scale = Vector2(0.8, 0.8)

	add_child(sprite)
	active_characters[character_name] = sprite

	sprite.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 1.0, 0.5)
	tween.tween_callback(func(): character_animation_finished.emit())
	await get_tree().create_timer(0.5).timeout

func hide_character(character_name: String) -> void:
	if character_name in active_characters:
		var sprite: Sprite2D = active_characters[character_name]
		var tween := create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
		tween.tween_callback(func():
			sprite.queue_free()
			active_characters.erase(character_name)
			character_animation_finished.emit()
		)
	await get_tree().create_timer(0.3).timeout

func change_expression(character_name: String, expression: String) -> void:
	if character_name in active_characters:
		var sprite: Sprite2D = active_characters[character_name]
		sprite.texture = _load_character_texture(character_name, expression)

func hide_all_characters() -> void:
	for name in active_characters.keys():
		hide_character(name)

func _load_character_texture(character_name: String, expression: String) -> Texture2D:
	var transparent_path := "res://assets/characters/%s_%s_transparent.png" % [character_name, expression]
	var regular_path := "res://assets/characters/%s_%s.png" % [character_name, expression]

	var path := ""
	if ResourceLoader.exists(transparent_path):
		path = transparent_path
	elif ResourceLoader.exists(regular_path):
		path = regular_path

	if path.is_empty():
		printerr("[CharacterManager] Image file not found for %s:%s" % [character_name, expression])
		return _create_placeholder_texture(character_name, expression)

	var image := Image.load_from_file(path)
	if image == null:
		printerr("[CharacterManager] Failed to load image at %s" % path)
		return _create_placeholder_texture(character_name, expression)

	image.convert(Image.FORMAT_RGBA8)
	var has_alpha := image.detect_alpha()
	var changed := false
	if not has_alpha:
		changed = _apply_alpha_from_white(image)
		if changed:
			image.fix_alpha_edges()

	var texture := ImageTexture.create_from_image(image)
	if changed:
		print("[CharacterManager] Converted white background to transparent for %s" % path)
	return texture

func _apply_alpha_from_white(image: Image) -> bool:
	var width := image.get_width()
	var height := image.get_height()
	var changed := false
	for y in range(height):
		for x in range(width):
			var color := image.get_pixel(x, y)
			if color.a > 0.0 and color.r >= 0.98 and color.g >= 0.98 and color.b >= 0.98:
				color.a = 0.0
				image.set_pixel(x, y, color)
				changed = true
	return changed

func _create_placeholder_texture(character_name: String, expression: String) -> ImageTexture:
	var image := Image.create(400, 800, false, Image.FORMAT_RGB8)
	var color := Color.GRAY
	match character_name:
		"mizuki":
			color = Color.CYAN
		"saori":
			color = Color.LIGHT_PINK
		"ruri":
			color = Color.LIGHT_BLUE
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
	_draw_simple_face(image, expression)

	var texture := ImageTexture.new()
	texture.set_image(image)
	return texture

func _draw_simple_face(image: Image, expression: String) -> void:
	var width := image.get_width()
	var height := image.get_height()
	var eye_y := int(height * 0.3)
	var left_eye_x := int(width * 0.3)
	var right_eye_x := int(width * 0.7)
	var mouth_y := int(height * 0.6)
	var mouth_x := int(width * 0.5)

	_draw_circle(image, Vector2i(left_eye_x, eye_y), 20, Color.BLACK)
	_draw_circle(image, Vector2i(right_eye_x, eye_y), 20, Color.BLACK)
	match expression:
		"smile":
			_draw_arc(image, Vector2i(mouth_x, mouth_y), 30, 0, PI, Color.BLACK)
		"sad":
			_draw_arc(image, Vector2i(mouth_x, mouth_y + 20), 30, PI, TAU, Color.BLACK)
		"angry":
			_draw_line(image, Vector2i(mouth_x - 30, mouth_y), Vector2i(mouth_x + 30, mouth_y), Color.BLACK)
		"surprised":
			_draw_circle(image, Vector2i(mouth_x, mouth_y), 15, Color.BLACK)
		_:
			_draw_line(image, Vector2i(mouth_x - 20, mouth_y), Vector2i(mouth_x + 20, mouth_y), Color.BLACK)

func _draw_circle(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	for y in range(center.y - radius, center.y + radius + 1):
		for x in range(center.x - radius, center.x + radius + 1):
			if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height():
				if Vector2(x - center.x, y - center.y).length() <= radius:
					image.set_pixel(x, y, color)

func _draw_line(image: Image, start: Vector2i, end: Vector2i, color: Color) -> void:
	var points := _bresenham(start, end)
	for point in points:
		if point.x >= 0 and point.x < image.get_width() and point.y >= 0 and point.y < image.get_height():
			image.set_pixel(point.x, point.y, color)

func _draw_arc(image: Image, center: Vector2i, radius: int, start_angle: float, end_angle: float, color: Color) -> void:
	var steps := 60
	for i in range(steps + 1):
		var angle := start_angle + (end_angle - start_angle) * i / steps
		var x := int(center.x + cos(angle) * radius)
		var y := int(center.y + sin(angle) * radius)
		if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height():
			image.set_pixel(x, y, color)

func _bresenham(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	var points: Array[Vector2i] = []
	var dx := abs(end.x - start.x)
	var dy := abs(end.y - start.y)
	var sx := 1 if start.x < end.x else -1
	var sy := 1 if start.y < end.y else -1
	var err := dx - dy
	var x := start.x
	var y := start.y
	while true:
		points.append(Vector2i(x, y))
		if x == end.x and y == end.y:
			break
		var e2 := 2 * err
		if e2 > -dy:
			err -= dy
			x += sx
		if e2 < dx:
			err += dx
			y += sy
	return points
