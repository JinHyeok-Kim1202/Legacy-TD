extends Node3D

const CAMERA_TARGET := Vector3(0, 0.35, 0)
const CAMERA_POSITION := Vector3(12.4, 15.4, 12.4)
const CAMERA_SIZE := 16.5

@onready var _board: Node = $GridBoard
@onready var _camera: Camera3D = $Camera3D
@onready var _hud: CanvasLayer = $MainHud

var _speed_multiplier: float = 1.0

func _ready() -> void:
	_configure_camera()
	_configure_environment()
	_build_backdrop()

	if _board.has_signal("tile_selected"):
		_board.tile_selected.connect(_on_board_tile_selected)

	if _board.has_signal("board_unit_selected"):
		_board.board_unit_selected.connect(_on_board_unit_selected)

	if _hud.has_signal("storage_unit_selected"):
		_hud.storage_unit_selected.connect(_on_storage_unit_selected)

	if _hud.has_signal("difficulty_selected"):
		_hud.difficulty_selected.connect(_on_difficulty_selected)

	if _hud.has_signal("story_slot_requested"):
		_hud.story_slot_requested.connect(_on_story_slot_requested)

	if _hud.has_signal("move_to_storage_requested"):
		_hud.move_to_storage_requested.connect(_on_move_to_storage_requested)

	if _hud.has_signal("speed_requested"):
		_hud.speed_requested.connect(_on_speed_requested)

	if _hud.has_signal("mission_boss_requested"):
		_hud.mission_boss_requested.connect(_on_mission_boss_requested)

	if _hud.has_signal("merge_requested"):
		_hud.merge_requested.connect(_on_merge_requested)

	if _hud.has_signal("restart_requested"):
		_hud.restart_requested.connect(_on_restart_requested)

	if _hud.has_signal("start_round_requested"):
		_hud.start_round_requested.connect(_on_start_round_requested)

	GameState.data_loaded.connect(_refresh_scene)
	GameState.storage_changed.connect(_refresh_hud)
	GameState.board_changed.connect(_refresh_scene)
	GameState.enemies_changed.connect(_refresh_enemies)
	GameState.round_state_changed.connect(_refresh_hud_live)
	GameState.selection_changed.connect(_refresh_selection)

	if not GameState.initialize():
		push_error(GameState.last_error)
		return

	_apply_speed_multiplier()
	_refresh_scene()


func _process(delta: float) -> void:
	var changed: bool = GameState.process_round(delta * _speed_multiplier)
	_refresh_hud_live()

	if _board.has_method("sync_enemies"):
		_board.sync_enemies(GameState.get_active_enemies(), GameState.path_tiles)


func _refresh_scene() -> void:
	if _board.has_method("configure_board"):
		_board.configure_board(GameState.board_rows, GameState.board_cols, GameState.path_tiles)

	_refresh_board_units()
	_refresh_enemies()
	_refresh_hud()


func _refresh_board_units() -> void:
	if _board.has_method("set_board_units"):
		_board.set_board_units(GameState.get_board_units(), GameState.selected_board_unit_instance_id)


func _refresh_enemies() -> void:
	if _board.has_method("sync_enemies"):
		_board.sync_enemies(GameState.get_active_enemies(), GameState.path_tiles)


func _refresh_hud() -> void:
	if _hud.has_method("refresh"):
		_hud.refresh()


func _refresh_hud_live() -> void:
	if _hud.has_method("refresh_live"):
		_hud.refresh_live()
	else:
		_refresh_hud()


func _refresh_selection() -> void:
	_refresh_board_units()
	if _hud.has_method("refresh_selection_only"):
		_hud.refresh_selection_only()
	else:
		_refresh_hud()


func _on_storage_unit_selected(instance_id: String) -> void:
	GameState.select_storage_unit_by_instance(instance_id)


func _on_difficulty_selected(next_difficulty_id: String) -> void:
	GameState.select_difficulty(next_difficulty_id)
	_refresh_scene()


func _on_merge_requested(recipe_id: String) -> void:
	if GameState.execute_merge(recipe_id):
		_refresh_scene()


func _on_story_slot_requested(slot_index: int) -> void:
	if GameState.place_selected_unit_to_story_slot(slot_index):
		_refresh_scene()


func _on_move_to_storage_requested() -> void:
	if GameState.move_selected_unit_to_storage():
		_refresh_scene()


func _on_speed_requested(multiplier: float) -> void:
	_speed_multiplier = multiplier
	_apply_speed_multiplier()
	_refresh_hud_live()


func _on_mission_boss_requested(mission_id: String) -> void:
	if GameState.summon_mission_boss(mission_id):
		_refresh_hud()


func _on_restart_requested() -> void:
	GameState.restart_run()
	_refresh_scene()


func _on_board_unit_selected(instance_id: String) -> void:
	if not GameState.selected_board_unit_instance_id.is_empty() and GameState.selected_board_unit_instance_id != instance_id:
		if GameState.swap_selected_board_unit_with(instance_id):
			_refresh_scene()
			return

	GameState.select_board_unit(instance_id)


func _on_board_tile_selected(row: int, col: int) -> void:
	if GameState.place_selected_unit(row, col):
		_refresh_board_units()
		_refresh_hud()


func _on_start_round_requested() -> void:
	if GameState.start_round():
		_refresh_enemies()
		_refresh_hud()


func _configure_camera() -> void:
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.size = CAMERA_SIZE
	_camera.position = CAMERA_POSITION
	_camera.near = 0.05
	_camera.far = 80.0
	_camera.look_at(CAMERA_TARGET, Vector3.UP)


func _apply_speed_multiplier() -> void:
	if _hud.has_method("set_speed_multiplier"):
		_hud.set_speed_multiplier(_speed_multiplier)


func _configure_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.07, 0.1, 0.13)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.62, 0.68, 0.76)
	environment.ambient_light_energy = 0.85
	$WorldEnvironment.environment = environment


func _build_backdrop() -> void:
	if has_node("Backdrop3D"):
		get_node("Backdrop3D").queue_free()

	var backdrop_root := Node3D.new()
	backdrop_root.name = "Backdrop3D"
	add_child(backdrop_root)

	backdrop_root.add_child(_create_backdrop_quad(
		Vector2(34.0, 26.0),
		Vector3(-10.0, 9.0, -10.0),
		Vector3(0.0, 45.0, 0.0),
		Color(0.15, 0.18, 0.21),
		true
	))
	backdrop_root.add_child(_create_backdrop_quad(
		Vector2(26.0, 8.0),
		Vector3(-8.8, 3.2, -8.8),
		Vector3(0.0, 45.0, 0.0),
		Color(0.11, 0.13, 0.16),
		true
	))
	backdrop_root.add_child(_create_backdrop_quad(
		Vector2(30.0, 30.0),
		Vector3(0.0, -0.34, 0.0),
		Vector3(-90.0, 0.0, 0.0),
		Color(0.08, 0.1, 0.11),
		false
	))

	for backdrop_shape in [
		{"size": Vector2(3.2, 7.2), "position": Vector3(-12.0, 3.5, -6.4), "color": Color(0.09, 0.11, 0.13)},
		{"size": Vector2(5.2, 8.8), "position": Vector3(-8.4, 4.3, -8.1), "color": Color(0.1, 0.12, 0.14)},
		{"size": Vector2(4.0, 6.6), "position": Vector3(-4.6, 3.2, -10.5), "color": Color(0.085, 0.1, 0.12)}
	]:
		backdrop_root.add_child(_create_backdrop_quad(
			backdrop_shape["size"],
			backdrop_shape["position"],
			Vector3(0.0, 45.0, 0.0),
			backdrop_shape["color"],
			true
		))


func _create_backdrop_quad(size: Vector2, position_value: Vector3, rotation_degrees_value: Vector3, color: Color, unshaded: bool) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var quad_mesh := QuadMesh.new()
	quad_mesh.size = size
	mesh_instance.mesh = quad_mesh
	mesh_instance.position = position_value
	mesh_instance.rotation_degrees = rotation_degrees_value

	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	if unshaded:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh_instance.material_override = material

	return mesh_instance
