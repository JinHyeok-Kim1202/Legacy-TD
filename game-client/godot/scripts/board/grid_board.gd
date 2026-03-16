extends Node3D

signal tile_selected(row: int, col: int)
signal board_unit_selected(instance_id: String)

const ActorViewFactory = preload("res://scripts/presentation/actor_view_factory.gd")
const TILE_SIZE := 1.6
const TILE_THICKNESS := 0.08
const BOARD_BASE_HEIGHT := 0.18

var _board_rows: int = 5
var _board_cols: int = 5
var _path_lookup: Dictionary = {}
var _enemy_nodes: Dictionary = {}


func configure_board(rows: int, cols: int, path_tiles: Array[Vector2i]) -> void:
	_board_rows = rows
	_board_cols = cols
	_path_lookup.clear()
	for tile: Vector2i in path_tiles:
		_path_lookup[_coord_key(tile)] = true

	_ensure_container("Tiles")
	_ensure_container("Units")
	_ensure_container("Enemies")
	_ensure_container("RangeIndicator")
	build_board()


func build_board() -> void:
	var tile_root: Node3D = _ensure_container("Tiles")
	for child in tile_root.get_children():
		child.queue_free()

	_build_board_base(tile_root)

	for row in range(_board_rows):
		for col in range(_board_cols):
			var tile_body: StaticBody3D = StaticBody3D.new()
			tile_body.position = _tile_world_position(row, col)
			tile_body.input_event.connect(_on_tile_input_event.bind(row, col))

			var tile_mesh: MeshInstance3D = MeshInstance3D.new()
			var mesh: BoxMesh = BoxMesh.new()
			mesh.size = Vector3(1.4, TILE_THICKNESS, 1.4)
			tile_mesh.mesh = mesh

			var material: StandardMaterial3D = StandardMaterial3D.new()
			material.albedo_color = _tile_color(row, col)
			tile_mesh.material_override = material
			tile_body.add_child(tile_mesh)

			var collision: CollisionShape3D = CollisionShape3D.new()
			var shape: BoxShape3D = BoxShape3D.new()
			shape.size = mesh.size
			collision.shape = shape
			tile_body.add_child(collision)

			tile_root.add_child(tile_body)


func set_board_units(board_units: Array[Dictionary], selected_unit_instance_id: String = "") -> void:
	var unit_root: Node3D = _ensure_container("Units")
	for child in unit_root.get_children():
		child.queue_free()

	var selected_occupant: Dictionary = {}
	for occupant: Dictionary in board_units:
		var unit: Dictionary = occupant.get("unit", {})
		var unit_instance_id: String = str(unit.get("instance_id", ""))
		var is_selected: bool = unit_instance_id == selected_unit_instance_id
		var unit_marker: StaticBody3D = ActorViewFactory.create_unit_marker(unit, is_selected)
		unit_marker.input_event.connect(_on_unit_input_event.bind(unit_instance_id))
		var position: Vector2i = occupant.get("position", Vector2i.ZERO)
		unit_marker.position = _tile_world_position(position.x, position.y) + Vector3(0, 0.42, 0)
		unit_root.add_child(unit_marker)
		if is_selected:
			selected_occupant = occupant

	_update_range_indicator(selected_occupant)


func sync_enemies(enemies: Array[Dictionary], path_tiles: Array[Vector2i]) -> void:
	var enemy_root: Node3D = _ensure_container("Enemies")
	var active_ids: Dictionary = {}

	for enemy: Dictionary in enemies:
		var enemy_id: String = str(enemy.get("instance_id", ""))
		active_ids[enemy_id] = true

		var enemy_node: Node3D = _enemy_nodes.get(enemy_id, null)
		if enemy_node == null:
			enemy_node = ActorViewFactory.create_enemy_marker(enemy)
			enemy_root.add_child(enemy_node)
			_enemy_nodes[enemy_id] = enemy_node

		enemy_node.position = _enemy_world_position(enemy, path_tiles)
		ActorViewFactory.update_enemy_marker(enemy_node, enemy)

	for enemy_id in _enemy_nodes.keys():
		if active_ids.has(enemy_id):
			continue

		var stale_node: Node3D = _enemy_nodes[enemy_id]
		stale_node.queue_free()
		_enemy_nodes.erase(enemy_id)


func _build_board_base(tile_root: Node3D) -> void:
	var board_width: float = float(_board_cols) * TILE_SIZE + 1.4
	var board_depth: float = float(_board_rows) * TILE_SIZE + 1.4

	var shadow_mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var shadow_mesh: QuadMesh = QuadMesh.new()
	shadow_mesh.size = Vector2(board_width * 1.1, board_depth * 1.1)
	shadow_mesh_instance.mesh = shadow_mesh
	shadow_mesh_instance.rotation_degrees.x = -90
	shadow_mesh_instance.position = Vector3(0, -0.24, 0)
	var shadow_material: StandardMaterial3D = StandardMaterial3D.new()
	shadow_material.albedo_color = Color(0.04, 0.05, 0.07, 0.65)
	shadow_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	shadow_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	shadow_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	shadow_mesh_instance.material_override = shadow_material
	tile_root.add_child(shadow_mesh_instance)

	var base_mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var base_mesh: BoxMesh = BoxMesh.new()
	base_mesh.size = Vector3(board_width, BOARD_BASE_HEIGHT, board_depth)
	base_mesh_instance.mesh = base_mesh
	base_mesh_instance.position = Vector3(0, -(BOARD_BASE_HEIGHT * 0.5) - 0.06, 0)
	var base_material: StandardMaterial3D = StandardMaterial3D.new()
	base_material.albedo_color = Color(0.12, 0.15, 0.18)
	base_material.roughness = 0.92
	base_mesh_instance.material_override = base_material
	tile_root.add_child(base_mesh_instance)


func _update_range_indicator(selected_occupant: Dictionary) -> void:
	var indicator_root: Node3D = _ensure_container("RangeIndicator")
	for child in indicator_root.get_children():
		child.queue_free()

	if selected_occupant.is_empty():
		return

	var unit: Dictionary = selected_occupant.get("unit", {})
	var attack_profile: Dictionary = unit.get("definition", {}).get("attack", {})
	var tile_position: Vector2i = selected_occupant.get("position", Vector2i.ZERO)
	var radius: float = float(attack_profile.get("range", 0.0)) * TILE_SIZE
	if radius <= 0.0:
		return

	var disk: MeshInstance3D = MeshInstance3D.new()
	var disk_mesh: CylinderMesh = CylinderMesh.new()
	disk_mesh.top_radius = radius
	disk_mesh.bottom_radius = radius
	disk_mesh.height = 0.02
	disk.mesh = disk_mesh
	disk.position = _tile_world_position(tile_position.x, tile_position.y) + Vector3(0, 0.055, 0)
	var disk_material: StandardMaterial3D = StandardMaterial3D.new()
	disk_material.albedo_color = Color(0.18, 0.8, 0.36, 0.08)
	disk_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	disk_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	disk_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	disk.material_override = disk_material
	indicator_root.add_child(disk)

	var ring: MeshInstance3D = MeshInstance3D.new()
	var ring_mesh: CylinderMesh = CylinderMesh.new()
	ring_mesh.top_radius = radius + 0.03
	ring_mesh.bottom_radius = radius + 0.03
	ring_mesh.height = 0.03
	ring.mesh = ring_mesh
	ring.position = _tile_world_position(tile_position.x, tile_position.y) + Vector3(0, 0.07, 0)
	var ring_material: StandardMaterial3D = StandardMaterial3D.new()
	ring_material.albedo_color = Color(0.22, 0.95, 0.42, 0.22)
	ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	ring.material_override = ring_material
	indicator_root.add_child(ring)


func _ensure_container(name: String) -> Node3D:
	if has_node(name):
		return get_node(name) as Node3D

	var node: Node3D = Node3D.new()
	node.name = name
	add_child(node)
	return node


func _tile_color(row: int, col: int) -> Color:
	if _path_lookup.has(_coord_key(Vector2i(row, col))):
		return Color(0.66, 0.59, 0.41)
	return Color(0.19, 0.26, 0.23)


func _tile_world_position(row: int, col: int) -> Vector3:
	var half_width: float = float(_board_cols - 1) * TILE_SIZE * 0.5
	var half_depth: float = float(_board_rows - 1) * TILE_SIZE * 0.5
	return Vector3((float(col) * TILE_SIZE) - half_width, 0, (float(row) * TILE_SIZE) - half_depth)


func _coord_key(position: Vector2i) -> String:
	return "%d:%d" % [position.x, position.y]


func _enemy_world_position(enemy: Dictionary, path_tiles: Array[Vector2i]) -> Vector3:
	if path_tiles.is_empty():
		return Vector3.ZERO

	var path_index: int = clamp(int(enemy.get("path_index", 0)), 0, path_tiles.size() - 1)
	var next_index: int = path_index + 1
	if next_index >= path_tiles.size():
		next_index = 0
	var progress: float = clamp(float(enemy.get("progress_to_next_tile", 0.0)), 0.0, 1.0)
	var start_tile: Vector2i = path_tiles[path_index]
	var end_tile: Vector2i = path_tiles[next_index]

	var start_position: Vector3 = _tile_world_position(start_tile.x, start_tile.y) + Vector3(0, 0.28, 0)
	var end_position: Vector3 = _tile_world_position(end_tile.x, end_tile.y) + Vector3(0, 0.28, 0)
	return start_position.lerp(end_position, progress)


func _on_tile_input_event(
	_camera: Node,
	event: InputEvent,
	_event_position: Vector3,
	_normal: Vector3,
	_shape_idx: int,
	row: int,
	col: int
) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tile_selected.emit(row, col)


func _on_unit_input_event(
	_camera: Node,
	event: InputEvent,
	_event_position: Vector3,
	_normal: Vector3,
	_shape_idx: int,
	instance_id: String
) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		board_unit_selected.emit(instance_id)
