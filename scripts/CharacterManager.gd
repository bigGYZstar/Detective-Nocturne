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

var position_map: Dictionary = {
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
	sprite.position = position_map[position]
	sprite.scale = Vector2(0.8, 0.8)

	add_child(sprite)
	active_characters[character_name] = sprite

	sprite.modulate.a = 1.0
	sprite.self_modulate.a = 1.0
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
			if sprite != null:
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

	var texture := load(path) as Texture2D
	if texture == null:
		printerr("[CharacterManager] Failed to load texture at %s" % path)
		return _create_placeholder_texture(character_name, expression)

	var image := texture.get_image()
	image.convert(Image.FORMAT_RGBA8)
	var background_palette := _collect_background_palette(image)
	var had_alpha := image.detect_alpha()
	var changed := false
	if background_palette.size() > 0:
		changed = _apply_palette_transparency(image, background_palette) or changed
	if not had_alpha:
		changed = _apply_alpha_from_white(image) or changed
	if changed:
		image.fix_alpha_edges()
	var final_texture := ImageTexture.create_from_image(image)
	if changed:
		print("[CharacterManager] Cleaned background for %s" % path)
	return final_texture

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
	var dx: int = abs(end.x - start.x)
	var dy: int = abs(end.y - start.y)
	var sx: int = 1 if start.x < end.x else -1
	var sy: int = 1 if start.y < end.y else -1
	var err: int = dx - dy
	var x: int = start.x
	var y: int = start.y
	while true:
		points.append(Vector2i(x, y))
		if x == end.x and y == end.y:
			break
		var e2: int = err * 2
		if e2 > -dy:
			err -= dy
			x += sx
		if e2 < dx:
			err += dx
			y += sy
	return points

func _collect_background_palette(image: Image, tolerance: float = 0.08, max_colors: int = 8, sample_step: int = 16) -> Array[Color]:
	var palette: Array[Color] = []
	var width := image.get_width()
	var height := image.get_height()
	var sample_points: Array[Vector2i] = []
	for x in range(0, width, max(1, sample_step)):
		sample_points.append(Vector2i(x, 0))
		sample_points.append(Vector2i(x, height - 1))
	for y in range(0, height, max(1, sample_step)):
		sample_points.append(Vector2i(0, y))
		sample_points.append(Vector2i(width - 1, y))
	sample_points.append(Vector2i(int(width / 2), 0))
	sample_points.append(Vector2i(int(width / 2), height - 1))
	sample_points.append(Vector2i(0, int(height / 2)))
	sample_points.append(Vector2i(width - 1, int(height / 2)))
	for sample_point in sample_points:
		var color := image.get_pixelv(sample_point)
		if color.a < 0.99:
			continue
		var add_color := true
		for existing in palette:
			if _is_color_similar(color, existing, tolerance):
				add_color = false
				break
		if add_color:
			palette.append(color)
			if palette.size() >= max_colors:
				break
	return palette

func _apply_palette_transparency(image: Image, palette: Array[Color], tolerance: float = 0.12) -> bool:
	var width := image.get_width()
	var height := image.get_height()
	var changed := false
	for y in range(height):
		for x in range(width):
			var color := image.get_pixel(x, y)
			if color.a < 0.01:
				continue
			for bg_color in palette:
				if _is_color_similar(color, bg_color, tolerance):
					color.a = 0.0
					image.set_pixel(x, y, color)
					changed = true
					break
	return changed

func _is_color_similar(a: Color, b: Color, tolerance: float) -> bool:
	var dr := a.r - b.r
	var dg := a.g - b.g
	var db := a.b - b.b
	return sqrt(dr * dr + dg * dg + db * db) <= tolerance
