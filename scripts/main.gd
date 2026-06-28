extends Node2D

const PAWN_TEXTURE_PATH := "res://assets/tiny_swords/Pawn_Blue.png"
const ENEMY_TEXTURE_PATH := "res://assets/tiny_swords/Warrior_Red.png"
const TREE_TEXTURE_PATH := "res://assets/tiny_swords/Tree.png"
const ROCK_TEXTURE_PATH := "res://assets/tiny_swords/04.png"
const BANNER_TEXTURE_PATH := "res://assets/tiny_swords/Banner_Horizontal.png"
const TILE_TEXTURE_PATH := "res://assets/tiny_swords/Tilemap_Flat.png"

const VIEW_SIZE := Vector2(1280.0, 720.0)
const ROAD_CENTER_Y := 380.0
const LANE_TOP_Y := ROAD_CENTER_Y - 88.0
const LANE_MID_Y := ROAD_CENTER_Y
const LANE_BOTTOM_Y := ROAD_CENTER_Y + 88.0
const FINISH_X := 3400.0
const START_COUNT := 6
const MAX_VISIBLE_MEMBERS := 40

var run_speed := 215.0
var lateral_speed := 430.0
var squad_count := START_COUNT
var elapsed := 0.0
var game_over := false

var world: Node2D
var squad: Node2D
var camera: Camera2D
var count_label: Label
var status_label: Label
var interactables: Array[Dictionary] = []
var pawn_texture: Texture2D
var enemy_texture: Texture2D
var tree_texture: Texture2D
var rock_texture: Texture2D
var banner_texture: Texture2D
var tile_texture: Texture2D


func _ready() -> void:
	_load_textures()
	_setup_camera()
	_build_world()
	_build_course()
	_build_hud()
	_reset_run()


func _process(delta: float) -> void:
	elapsed += delta

	if Input.is_key_pressed(KEY_R):
		_reset_run()
		return

	if game_over:
		return

	_move_squad(delta)
	_check_interactions()
	_refresh_member_animation()
	_update_camera()
	_update_hud()

	if squad.position.x >= FINISH_X:
		game_over = true
		status_label.text = "FINISH  |  SCORE %d" % squad_count


func _setup_camera() -> void:
	camera = Camera2D.new()
	camera.name = "Camera2D"
	camera.enabled = true
	camera.position = Vector2(VIEW_SIZE.x * 0.5, VIEW_SIZE.y * 0.5)
	add_child(camera)


func _build_world() -> void:
	world = Node2D.new()
	world.name = "World"
	world.y_sort_enabled = true
	add_child(world)

	_add_rect("Sky", Vector2(-600.0, 0.0), Vector2(FINISH_X + 1600.0, 720.0), Color(0.48, 0.76, 0.96))
	_add_rect("GrassTop", Vector2(-600.0, 0.0), Vector2(FINISH_X + 1600.0, 224.0), Color(0.36, 0.68, 0.38))
	_add_rect("GrassBottom", Vector2(-600.0, 540.0), Vector2(FINISH_X + 1600.0, 220.0), Color(0.30, 0.60, 0.34))
	_add_rect("Road", Vector2(-600.0, 222.0), Vector2(FINISH_X + 1600.0, 316.0), Color(0.76, 0.67, 0.49))

	for x in range(-520, int(FINISH_X + 820), 64):
		for y in range(252, 520, 64):
			_add_decoration(tile_texture, Vector2(float(x), float(y)), Rect2(0, 0, 64, 64), 1.0)

	for y in [LANE_TOP_Y + 44.0, LANE_MID_Y + 44.0]:
		for x in range(-520, int(FINISH_X + 820), 120):
			_add_rect("LaneDash", Vector2(float(x), y), Vector2(58.0, 5.0), Color(0.92, 0.85, 0.66, 0.7))

	for x in range(120, int(FINISH_X), 420):
		_add_decoration(tree_texture, Vector2(float(x), 168.0), Rect2(0, 0, 192, 192), 0.42)
		_add_decoration(rock_texture, Vector2(float(x + 190), 570.0), Rect2(0, 0, 64, 64), 1.25)


func _build_course() -> void:
	_spawn_gate_pair(660.0, "+5", "add", 5, "x2", "mul", 2)
	_spawn_enemy(1020.0, LANE_MID_Y, 2)
	_spawn_recruit(1240.0, LANE_TOP_Y, 3)
	_spawn_gate_pair(1510.0, "+8", "add", 8, "-4", "add", -4)
	_spawn_enemy(1810.0, LANE_BOTTOM_Y, 4)
	_spawn_recruit(2050.0, LANE_BOTTOM_Y, 4)
	_spawn_gate_pair(2350.0, "x2", "mul", 2, "-8", "add", -8)
	_spawn_enemy(2710.0, LANE_TOP_Y, 6)
	_spawn_enemy(2920.0, LANE_MID_Y, 5)
	_spawn_finish()


func _build_hud() -> void:
	var hud := CanvasLayer.new()
	hud.name = "HUD"
	add_child(hud)

	count_label = _make_label("SQUAD 0", 28)
	count_label.position = Vector2(28.0, 22.0)
	hud.add_child(count_label)

	status_label = _make_label("", 34)
	status_label.position = Vector2(410.0, 22.0)
	hud.add_child(status_label)


func _reset_run() -> void:
	squad_count = START_COUNT
	game_over = false
	status_label.text = ""

	if squad == null:
		squad = Node2D.new()
		squad.name = "Squad"
		world.add_child(squad)

	squad.position = Vector2(120.0, LANE_MID_Y)
	_refresh_squad_members()
	_update_camera()
	_update_hud()

	for data in interactables:
		data["used"] = false
		var node := data["node"] as Node2D
		if node:
			node.modulate = Color.WHITE


func _move_squad(delta: float) -> void:
	squad.position.x += run_speed * delta

	var input_y := 0.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_y += 1.0

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_y := get_global_mouse_position().y
		squad.position.y = move_toward(squad.position.y, clamp(mouse_y, LANE_TOP_Y, LANE_BOTTOM_Y), lateral_speed * delta)
	elif input_y != 0.0:
		squad.position.y = clamp(squad.position.y + input_y * lateral_speed * delta, LANE_TOP_Y, LANE_BOTTOM_Y)


func _check_interactions() -> void:
	for data in interactables:
		if data["used"]:
			continue
		if absf(squad.position.x - data["x"]) > data["radius_x"]:
			continue
		if absf(squad.position.y - data["y"]) > data["radius_y"]:
			continue

		data["used"] = true
		var node := data["node"] as Node2D
		if node:
			node.modulate = Color(1.0, 1.0, 1.0, 0.32)

		match data["type"]:
			"gate":
				_apply_gate(data["op"], data["value"])
			"enemy":
				_change_count(-int(data["damage"]))
			"recruit":
				_change_count(int(data["amount"]))


func _apply_gate(operation: String, value: int) -> void:
	match operation:
		"add":
			_change_count(value)
		"mul":
			squad_count = clampi(squad_count * value, 1, 99)
			_refresh_squad_members()


func _change_count(amount: int) -> void:
	squad_count = clampi(squad_count + amount, 1, 99)
	_refresh_squad_members()


func _refresh_squad_members() -> void:
	for child in squad.get_children():
		squad.remove_child(child)
		child.queue_free()

	var visible_count := mini(squad_count, MAX_VISIBLE_MEMBERS)
	for index in visible_count:
		var sprite := _make_unit_sprite(pawn_texture, Rect2(0, 0, 192, 192), 0.34)
		var row := index / 7
		var col := index % 7
		sprite.position = Vector2(-float(row) * 22.0, (float(col) - 3.0) * 18.0)
		sprite.z_index = index
		squad.add_child(sprite)


func _refresh_member_animation() -> void:
	var frame := int(elapsed * 9.0) % 6
	for child in squad.get_children():
		var sprite := child as Sprite2D
		if sprite:
			sprite.region_rect = Rect2(frame * 192, 0, 192, 192)
			sprite.position.y += sin(elapsed * 10.0 + float(sprite.z_index)) * 0.03


func _update_camera() -> void:
	camera.position.x = maxf(VIEW_SIZE.x * 0.5, squad.position.x + 360.0)
	camera.position.y = VIEW_SIZE.y * 0.5


func _update_hud() -> void:
	count_label.text = "SQUAD %d" % squad_count


func _spawn_gate_pair(x: float, top_text: String, top_op: String, top_value: int, bottom_text: String, bottom_op: String, bottom_value: int) -> void:
	_spawn_gate(x, LANE_TOP_Y, top_text, top_op, top_value, Color(0.18, 0.58, 0.96, 0.9))
	_spawn_gate(x, LANE_BOTTOM_Y, bottom_text, bottom_op, bottom_value, Color(0.92, 0.22, 0.20, 0.9) if bottom_text.begins_with("-") else Color(0.19, 0.70, 0.34, 0.9))


func _spawn_gate(x: float, y: float, text: String, op: String, value: int, color: Color) -> void:
	var gate := Node2D.new()
	gate.name = "Gate_%s" % text
	gate.position = Vector2(x, y)
	world.add_child(gate)

	var panel := _add_local_rect(gate, Vector2(-46.0, -54.0), Vector2(92.0, 108.0), color)
	panel.z_index = -1
	var label := _make_label(text, 28)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-46.0, -18.0)
	label.size = Vector2(92.0, 42.0)
	gate.add_child(label)

	interactables.append({
		"type": "gate",
		"node": gate,
		"x": x,
		"y": y,
		"radius_x": 48.0,
		"radius_y": 58.0,
		"op": op,
		"value": value,
		"used": false,
	})


func _spawn_enemy(x: float, y: float, damage: int) -> void:
	var enemy := Node2D.new()
	enemy.name = "Enemy_%d" % damage
	enemy.position = Vector2(x, y)
	world.add_child(enemy)

	var sprite := _make_unit_sprite(enemy_texture, Rect2(0, 0, 192, 192), 0.38)
	enemy.add_child(sprite)

	var label := _make_label("-%d" % damage, 22)
	label.position = Vector2(-22.0, -72.0)
	enemy.add_child(label)

	interactables.append({
		"type": "enemy",
		"node": enemy,
		"x": x,
		"y": y,
		"radius_x": 42.0,
		"radius_y": 46.0,
		"damage": damage,
		"used": false,
	})


func _spawn_recruit(x: float, y: float, amount: int) -> void:
	var pickup := Node2D.new()
	pickup.name = "Recruit_%d" % amount
	pickup.position = Vector2(x, y)
	world.add_child(pickup)

	for index in amount:
		var sprite := _make_unit_sprite(pawn_texture, Rect2(0, 0, 192, 192), 0.25)
		sprite.position = Vector2((float(index) - float(amount - 1) * 0.5) * 18.0, 0.0)
		pickup.add_child(sprite)

	var label := _make_label("+%d" % amount, 22)
	label.position = Vector2(-24.0, -70.0)
	pickup.add_child(label)

	interactables.append({
		"type": "recruit",
		"node": pickup,
		"x": x,
		"y": y,
		"radius_x": 48.0,
		"radius_y": 54.0,
		"amount": amount,
		"used": false,
	})


func _spawn_finish() -> void:
	_add_rect("FinishLine", Vector2(FINISH_X, 222.0), Vector2(18.0, 316.0), Color(1.0, 1.0, 1.0))
	for index in 6:
		var banner := Sprite2D.new()
		banner.texture = banner_texture
		banner.region_enabled = true
		banner.region_rect = Rect2(0, 0, 192, 192)
		banner.scale = Vector2(0.45, 0.45)
		banner.position = Vector2(FINISH_X + 38.0, 238.0 + float(index) * 55.0)
		world.add_child(banner)

	var label := _make_label("FINISH", 30)
	label.position = Vector2(FINISH_X - 46.0, 164.0)
	world.add_child(label)


func _add_rect(node_name: String, position_value: Vector2, size_value: Vector2, color: Color) -> Polygon2D:
	var rect := Polygon2D.new()
	rect.name = node_name
	rect.position = position_value
	rect.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(size_value.x, 0.0),
		size_value,
		Vector2(0.0, size_value.y),
	])
	rect.color = color
	world.add_child(rect)
	return rect


func _load_textures() -> void:
	pawn_texture = _load_png_texture(PAWN_TEXTURE_PATH)
	enemy_texture = _load_png_texture(ENEMY_TEXTURE_PATH)
	tree_texture = _load_png_texture(TREE_TEXTURE_PATH)
	rock_texture = _load_png_texture(ROCK_TEXTURE_PATH)
	banner_texture = _load_png_texture(BANNER_TEXTURE_PATH)
	tile_texture = _load_png_texture(TILE_TEXTURE_PATH)


func _load_png_texture(path: String) -> Texture2D:
	var imported_texture := load(path) as Texture2D
	if imported_texture != null:
		return imported_texture

	var image := Image.new()
	var error := image.load(path)
	if error != OK:
		push_error("Failed to load texture: %s" % path)
		return ImageTexture.create_from_image(Image.create(8, 8, false, Image.FORMAT_RGBA8))
	return ImageTexture.create_from_image(image)


func _add_local_rect(parent: Node, position_value: Vector2, size_value: Vector2, color: Color) -> Polygon2D:
	var rect := Polygon2D.new()
	rect.position = position_value
	rect.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(size_value.x, 0.0),
		size_value,
		Vector2(0.0, size_value.y),
	])
	rect.color = color
	parent.add_child(rect)
	return rect


func _add_decoration(texture: Texture2D, position_value: Vector2, region: Rect2, sprite_scale: float) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.region_enabled = true
	sprite.region_rect = region
	sprite.scale = Vector2(sprite_scale, sprite_scale)
	sprite.position = position_value
	world.add_child(sprite)


func _make_unit_sprite(texture: Texture2D, region: Rect2, sprite_scale: float) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.region_enabled = true
	sprite.region_rect = region
	sprite.centered = true
	sprite.scale = Vector2(sprite_scale, sprite_scale)
	return sprite


func _make_label(text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.75))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	return label
