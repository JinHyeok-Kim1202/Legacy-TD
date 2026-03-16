extends RefCounted

class_name ActorViewFactory

const ENEMY_HP_BAR_WIDTH := 0.78
const ENEMY_HP_BAR_HEIGHT := 0.1
const SPRITE_PIXEL_SIZE := 0.0125

static var _unit_body_texture: Texture2D
static var _unit_cloak_texture: Texture2D
static var _unit_head_texture: Texture2D
static var _unit_helm_texture: Texture2D
static var _unit_weapon_texture: Texture2D
static var _enemy_body_texture: Texture2D
static var _enemy_shell_texture: Texture2D
static var _enemy_horns_texture: Texture2D
static var _enemy_eyes_texture: Texture2D


static func create_unit_icon_texture(unit: Dictionary) -> Texture2D:
	var image: Image = _make_blank_image()
	var palette: Dictionary = _unit_palette(str(unit.get("rarity", "")))
	_blend_tinted_image(image, _get_unit_cloak_texture().get_image(), palette.get("accent", Color.WHITE))
	_blend_tinted_image(image, _get_unit_body_texture().get_image(), palette.get("armor", Color.WHITE))
	_blend_tinted_image(image, _get_unit_head_texture().get_image(), palette.get("skin", Color.WHITE))
	_blend_tinted_image(image, _get_unit_helm_texture().get_image(), palette.get("metal", Color.WHITE))
	_blend_tinted_image(image, _get_unit_weapon_texture().get_image(), palette.get("weapon", Color.WHITE))
	return ImageTexture.create_from_image(image)


static func create_unit_marker(unit: Dictionary, is_selected: bool) -> StaticBody3D:
	var root: StaticBody3D = StaticBody3D.new()
	root.name = str(unit.get("instance_id", "unit_marker"))

	root.add_child(_create_shadow(Vector2(0.74, 0.48), Vector3(0, -0.36, 0), 0.55))

	var palette: Dictionary = _unit_palette(str(unit.get("rarity", "")))
	root.add_child(_create_billboard_sprite("CloakSprite", _get_unit_cloak_texture(), palette.get("accent", Color.WHITE), Vector3(0, 0.02, 0.08), Vector3(0.9, 0.9, 1)))
	root.add_child(_create_billboard_sprite("BodySprite", _get_unit_body_texture(), palette.get("armor", Color.WHITE), Vector3(0, 0.1, 0), Vector3(0.84, 0.84, 1), is_selected))
	root.add_child(_create_billboard_sprite("HeadSprite", _get_unit_head_texture(), palette.get("skin", Color.WHITE), Vector3(0, 0.42, 0.01), Vector3(0.52, 0.52, 1)))
	root.add_child(_create_billboard_sprite("HelmSprite", _get_unit_helm_texture(), palette.get("metal", Color.WHITE), Vector3(0, 0.49, 0.02), Vector3(0.58, 0.58, 1)))
	root.add_child(_create_billboard_sprite("WeaponSprite", _get_unit_weapon_texture(), palette.get("weapon", Color.WHITE), Vector3(0.34, 0.02, 0.02), Vector3(0.72, 0.72, 1)))

	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: CylinderShape3D = CylinderShape3D.new()
	shape.radius = 0.36
	shape.height = 0.82
	collision.shape = shape
	collision.position = Vector3(0, 0.1, 0)
	root.add_child(collision)

	var label: Label3D = Label3D.new()
	label.text = _unit_label(unit)
	label.position = Vector3(0, 0.72, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 34
	label.modulate = Color(0.97, 0.98, 1.0, 0.98)
	root.add_child(label)

	return root


static func create_enemy_marker(enemy: Dictionary) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = str(enemy.get("instance_id", "enemy_marker"))

	var is_boss: bool = bool(enemy.get("is_boss", false))
	var palette: Dictionary = _enemy_palette(is_boss)
	var scale_multiplier: Vector3 = Vector3(1.18, 1.18, 1) if is_boss else Vector3.ONE

	root.add_child(_create_shadow(Vector2(0.62, 0.38) if not is_boss else Vector2(0.9, 0.56), Vector3(0, -0.26, 0), 0.5))
	root.add_child(_create_billboard_sprite("BodySprite", _get_enemy_body_texture(), palette.get("body", Color.WHITE), Vector3(0, 0.02, 0), Vector3(0.84, 0.84, 1) * scale_multiplier))
	root.add_child(_create_billboard_sprite("ShellSprite", _get_enemy_shell_texture(), palette.get("shell", Color.WHITE), Vector3(0, 0.1, 0.04), Vector3(0.92, 0.78, 1) * scale_multiplier))
	root.add_child(_create_billboard_sprite("HornSprite", _get_enemy_horns_texture(), palette.get("horn", Color.WHITE), Vector3(0, 0.34 if not is_boss else 0.46, 0.02), Vector3(0.8, 0.8, 1) * scale_multiplier))
	root.add_child(_create_billboard_sprite("EyeSprite", _get_enemy_eyes_texture(), palette.get("eye", Color.WHITE), Vector3(0, 0.12 if not is_boss else 0.18, -0.14), Vector3(0.48, 0.48, 1) * scale_multiplier, false, true))

	var hp_bar_root: Node3D = Node3D.new()
	hp_bar_root.name = "HpBarRoot"
	hp_bar_root.top_level = true
	root.add_child(hp_bar_root)

	var hp_bar_background: MeshInstance3D = MeshInstance3D.new()
	hp_bar_background.name = "HpBarBackground"
	var background_mesh: QuadMesh = QuadMesh.new()
	background_mesh.size = Vector2(ENEMY_HP_BAR_WIDTH, ENEMY_HP_BAR_HEIGHT)
	hp_bar_background.mesh = background_mesh
	hp_bar_background.material_override = _make_unshaded_material(Color(0.08, 0.09, 0.1, 0.72))
	hp_bar_root.add_child(hp_bar_background)

	var hp_bar_fill: MeshInstance3D = MeshInstance3D.new()
	hp_bar_fill.name = "HpBarFill"
	var fill_mesh: QuadMesh = QuadMesh.new()
	fill_mesh.size = Vector2(ENEMY_HP_BAR_WIDTH, ENEMY_HP_BAR_HEIGHT * 0.72)
	hp_bar_fill.mesh = fill_mesh
	hp_bar_fill.position = Vector3(0, 0, 0.001)
	hp_bar_fill.material_override = _make_unshaded_material(Color(0.2, 0.92, 0.34, 0.92))
	hp_bar_root.add_child(hp_bar_fill)

	return root


static func update_enemy_marker(enemy_node: Node3D, enemy: Dictionary) -> void:
	var body_sprite: Sprite3D = enemy_node.get_node_or_null("BodySprite") as Sprite3D
	var hp_bar_root: Node3D = enemy_node.get_node_or_null("HpBarRoot") as Node3D
	var hp_bar_fill: MeshInstance3D = enemy_node.get_node_or_null("HpBarRoot/HpBarFill") as MeshInstance3D
	if body_sprite == null or hp_bar_root == null or hp_bar_fill == null:
		return

	hp_bar_root.global_position = enemy_node.global_position + Vector3(0, 0.52 if not bool(enemy.get("is_boss", false)) else 0.72, 0)
	var camera: Camera3D = enemy_node.get_viewport().get_camera_3d()
	if camera != null:
		hp_bar_root.look_at(camera.global_position, Vector3.UP, true)

	var max_hp: float = max(1.0, float(enemy.get("max_hp", 1)))
	var current_hp: float = max(0.0, float(enemy.get("current_hp", 0)))
	var hp_ratio: float = clamp(current_hp / max_hp, 0.0, 1.0)
	hp_bar_fill.scale.x = hp_ratio
	hp_bar_fill.position.x = -((1.0 - hp_ratio) * ENEMY_HP_BAR_WIDTH * 0.5)

	var fill_material: StandardMaterial3D = hp_bar_fill.material_override as StandardMaterial3D
	if fill_material != null:
		fill_material.albedo_color = _health_bar_color(hp_ratio)

	var palette: Dictionary = _enemy_palette(bool(enemy.get("is_boss", false)))
	if float(enemy.get("hit_flash_remaining", 0.0)) > 0.0:
		body_sprite.modulate = Color(1.0, 0.94, 0.88, 1.0)
	else:
		body_sprite.modulate = palette.get("body", Color.WHITE)


static func _create_shadow(size: Vector2, position_value: Vector3, alpha_value: float) -> MeshInstance3D:
	var shadow: MeshInstance3D = MeshInstance3D.new()
	var shadow_mesh: QuadMesh = QuadMesh.new()
	shadow_mesh.size = size
	shadow.mesh = shadow_mesh
	shadow.rotation_degrees.x = -90
	shadow.position = position_value
	shadow.material_override = _make_unshaded_material(Color(0.02, 0.03, 0.04, alpha_value))
	return shadow


static func _create_billboard_sprite(
	name: String,
	texture: Texture2D,
	color: Color,
	position_value: Vector3,
	scale_value: Vector3,
	emission_enabled: bool = false,
	unshaded: bool = false
) -> Sprite3D:
	var sprite: Sprite3D = Sprite3D.new()
	sprite.name = name
	sprite.texture = texture
	sprite.position = position_value
	sprite.scale = scale_value
	sprite.pixel_size = SPRITE_PIXEL_SIZE
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.modulate = color
	if emission_enabled:
		sprite.modulate = color.lightened(0.18)
	if unshaded:
		sprite.shaded = false
	return sprite


static func _unit_palette(rarity: String) -> Dictionary:
	var base_armor: Color = _unit_color(rarity)
	return {
		"armor": base_armor,
		"accent": base_armor.lightened(0.16),
		"metal": Color(0.82, 0.84, 0.9),
		"weapon": Color(0.78, 0.72, 0.56),
		"skin": Color(0.86, 0.74, 0.6),
	}


static func _enemy_palette(is_boss: bool) -> Dictionary:
	if is_boss:
		return {
			"body": Color(0.45, 0.08, 0.08),
			"shell": Color(0.2, 0.02, 0.04),
			"horn": Color(0.72, 0.44, 0.22),
			"eye": Color(1.0, 0.58, 0.2),
		}
	return {
		"body": Color(0.8, 0.18, 0.16),
		"shell": Color(0.3, 0.04, 0.05),
		"horn": Color(0.58, 0.36, 0.18),
		"eye": Color(1.0, 0.74, 0.22),
	}


static func _make_unshaded_material(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material


static func _unit_color(rarity: String) -> Color:
	match rarity:
		"common":
			return Color(1.0, 1.0, 1.0)
		"rare":
			return Color(0.22, 0.45, 1.0)
		"unique":
			return Color(0.62, 0.32, 0.92)
		"legendary":
			return Color(0.92, 0.18, 0.18)
		"transcendent":
			return Color(0.42, 0.95, 0.82)
		"immortal":
			return Color(1.0, 0.58, 0.18)
		"god":
			return Color(0.42, 0.82, 1.0)
		"liberator":
			return Color(0.18, 0.82, 0.28)
		_:
			return Color(1.0, 1.0, 1.0)


static func _health_bar_color(hp_ratio: float) -> Color:
	if hp_ratio <= 0.25:
		return Color(0.9, 0.18, 0.14, 0.96)
	if hp_ratio <= 0.5:
		return Color(0.94, 0.48, 0.14, 0.96)
	if hp_ratio <= 0.75:
		return Color(0.96, 0.82, 0.18, 0.96)
	return Color(0.22, 0.92, 0.34, 0.96)


static func _unit_label(unit: Dictionary) -> String:
	var display_name: String = str(unit.get("display_name", "Unit"))
	var name_parts: PackedStringArray = display_name.split(" ", false)
	if name_parts.is_empty():
		return display_name
	return name_parts[0]


static func _get_unit_body_texture() -> Texture2D:
	if _unit_body_texture != null:
		return _unit_body_texture

	var image: Image = _make_blank_image()
	image.fill_rect(Rect2i(20, 16, 24, 10), Color.WHITE)
	image.fill_rect(Rect2i(18, 24, 28, 16), Color.WHITE)
	image.fill_rect(Rect2i(22, 40, 20, 14), Color.WHITE)
	image.fill_rect(Rect2i(14, 26, 8, 10), Color.WHITE)
	image.fill_rect(Rect2i(42, 26, 8, 10), Color.WHITE)
	_unit_body_texture = ImageTexture.create_from_image(image)
	return _unit_body_texture


static func _get_unit_cloak_texture() -> Texture2D:
	if _unit_cloak_texture != null:
		return _unit_cloak_texture

	var image: Image = _make_blank_image()
	image.fill_rect(Rect2i(22, 18, 20, 8), Color.WHITE)
	image.fill_rect(Rect2i(18, 26, 28, 10), Color.WHITE)
	image.fill_rect(Rect2i(14, 36, 36, 18), Color.WHITE)
	_unit_cloak_texture = ImageTexture.create_from_image(image)
	return _unit_cloak_texture


static func _get_unit_head_texture() -> Texture2D:
	if _unit_head_texture != null:
		return _unit_head_texture

	var image: Image = _make_blank_image()
	_draw_circle(image, Vector2i(32, 32), 12, Color.WHITE)
	_unit_head_texture = ImageTexture.create_from_image(image)
	return _unit_head_texture


static func _get_unit_helm_texture() -> Texture2D:
	if _unit_helm_texture != null:
		return _unit_helm_texture

	var image: Image = _make_blank_image()
	_draw_circle(image, Vector2i(32, 30), 13, Color.WHITE)
	image.fill_rect(Rect2i(18, 30, 28, 18), Color(0, 0, 0, 0))
	image.fill_rect(Rect2i(30, 10, 4, 10), Color.WHITE)
	_unit_helm_texture = ImageTexture.create_from_image(image)
	return _unit_helm_texture


static func _get_unit_weapon_texture() -> Texture2D:
	if _unit_weapon_texture != null:
		return _unit_weapon_texture

	var image: Image = _make_blank_image()
	image.fill_rect(Rect2i(30, 14, 4, 34), Color.WHITE)
	image.fill_rect(Rect2i(26, 10, 12, 6), Color.WHITE)
	image.fill_rect(Rect2i(28, 6, 8, 4), Color.WHITE)
	image.fill_rect(Rect2i(24, 46, 16, 4), Color.WHITE)
	_unit_weapon_texture = ImageTexture.create_from_image(image)
	return _unit_weapon_texture


static func _get_enemy_body_texture() -> Texture2D:
	if _enemy_body_texture != null:
		return _enemy_body_texture

	var image: Image = _make_blank_image()
	_draw_circle(image, Vector2i(32, 36), 18, Color.WHITE)
	image.fill_rect(Rect2i(14, 40, 36, 12), Color.WHITE)
	_enemy_body_texture = ImageTexture.create_from_image(image)
	return _enemy_body_texture


static func _get_enemy_shell_texture() -> Texture2D:
	if _enemy_shell_texture != null:
		return _enemy_shell_texture

	var image: Image = _make_blank_image()
	_draw_circle(image, Vector2i(32, 30), 18, Color.WHITE)
	image.fill_rect(Rect2i(12, 30, 40, 20), Color.WHITE)
	image.fill_rect(Rect2i(0, 42, 64, 22), Color(0, 0, 0, 0))
	_enemy_shell_texture = ImageTexture.create_from_image(image)
	return _enemy_shell_texture


static func _get_enemy_horns_texture() -> Texture2D:
	if _enemy_horns_texture != null:
		return _enemy_horns_texture

	var image: Image = _make_blank_image()
	image.fill_rect(Rect2i(12, 20, 8, 12), Color.WHITE)
	image.fill_rect(Rect2i(16, 10, 6, 12), Color.WHITE)
	image.fill_rect(Rect2i(44, 20, 8, 12), Color.WHITE)
	image.fill_rect(Rect2i(42, 10, 6, 12), Color.WHITE)
	_enemy_horns_texture = ImageTexture.create_from_image(image)
	return _enemy_horns_texture


static func _get_enemy_eyes_texture() -> Texture2D:
	if _enemy_eyes_texture != null:
		return _enemy_eyes_texture

	var image: Image = _make_blank_image()
	_draw_circle(image, Vector2i(22, 32), 5, Color.WHITE)
	_draw_circle(image, Vector2i(42, 32), 5, Color.WHITE)
	_enemy_eyes_texture = ImageTexture.create_from_image(image)
	return _enemy_eyes_texture


static func _make_blank_image() -> Image:
	var image: Image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	return image


static func _draw_circle(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	for y in range(-radius, radius + 1):
		for x in range(-radius, radius + 1):
			if x * x + y * y > radius * radius:
				continue
			var px: int = center.x + x
			var py: int = center.y + y
			if px < 0 or py < 0 or px >= image.get_width() or py >= image.get_height():
				continue
			image.set_pixel(px, py, color)


static func _blend_tinted_image(target: Image, source: Image, tint: Color) -> void:
	for y in range(source.get_height()):
		for x in range(source.get_width()):
			var pixel: Color = source.get_pixel(x, y)
			if pixel.a <= 0.0:
				continue

			var tinted := Color(
				pixel.r * tint.r,
				pixel.g * tint.g,
				pixel.b * tint.b,
				pixel.a * tint.a
			)
			var destination: Color = target.get_pixel(x, y)
			var out_alpha: float = tinted.a + destination.a * (1.0 - tinted.a)
			if out_alpha <= 0.0:
				target.set_pixel(x, y, Color(0, 0, 0, 0))
				continue

			var out_color := Color(
				(tinted.r * tinted.a + destination.r * destination.a * (1.0 - tinted.a)) / out_alpha,
				(tinted.g * tinted.a + destination.g * destination.a * (1.0 - tinted.a)) / out_alpha,
				(tinted.b * tinted.a + destination.b * destination.a * (1.0 - tinted.a)) / out_alpha,
				out_alpha
			)
			target.set_pixel(x, y, out_color)
