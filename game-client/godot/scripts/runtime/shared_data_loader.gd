extends RefCounted

class_name SharedDataLoader

const DATA_ROOT := "../../game-shared/data"

var last_error: String = ""


func load_all() -> Dictionary:
	last_error = ""

	var board_data: Dictionary = _load_json("boards/board_5x5.json", "board_id")
	if not last_error.is_empty():
		return {}

	var paths_data: Dictionary = _load_json("boards/paths.json", "paths")
	if not last_error.is_empty():
		return {}

	var units_data: Dictionary = _load_json("units/units.json", "units")
	if not last_error.is_empty():
		return {}

	var enemies_data: Dictionary = _load_json("enemies/enemies.json", "enemies")
	if not last_error.is_empty():
		return {}

	var bosses_data: Dictionary = _load_json("enemies/bosses.json", "bosses")
	if not last_error.is_empty():
		return {}

	var waves_data: Dictionary = _load_json("progression/waves.json", "waves")
	if not last_error.is_empty():
		return {}

	var recipes_data: Dictionary = _load_json("progression/recipes.json", "recipes")
	if not last_error.is_empty():
		return {}

	var difficulties_data: Dictionary = _load_json("progression/difficulties.json", "difficulties")
	if not last_error.is_empty():
		return {}

	var story_bosses_data: Dictionary = _load_json("progression/story_bosses.json", "stages")
	if not last_error.is_empty():
		return {}

	var mission_bosses_data: Dictionary = _load_json("progression/mission_bosses.json", "missions")
	if not last_error.is_empty():
		return {}

	var rewards_data: Dictionary = _load_json("progression/rewards.json", "round_draw_rules")
	if not last_error.is_empty():
		return {}

	var path_tiles: Array[Vector2i] = _resolve_path_tiles(board_data, paths_data)
	if path_tiles.is_empty():
		last_error = "Board path tiles could not be resolved from shared JSON."
		return {}

	var units: Array = units_data.get("units", [])
	var enemies: Array = enemies_data.get("enemies", [])
	var bosses: Array = bosses_data.get("bosses", [])
	var waves: Array = waves_data.get("waves", [])
	var recipes: Array = recipes_data.get("recipes", [])
	var difficulties: Array = difficulties_data.get("difficulties", [])
	var story_stages: Array = story_bosses_data.get("stages", [])
	var mission_bosses: Array = mission_bosses_data.get("missions", [])
	var round_draw_rules: Dictionary = rewards_data.get("round_draw_rules", {})
	var currencies: Array = rewards_data.get("currencies", [])

	return {
		"board": board_data,
		"path_tiles": path_tiles,
		"units": units,
		"common_unit_ids": _collect_common_unit_ids(units),
		"unit_ids_by_rarity": _collect_unit_ids_by_rarity(units),
		"units_by_id": _map_by_id(units),
		"enemies": enemies,
		"enemies_by_id": _map_by_id(enemies),
		"bosses": bosses,
		"bosses_by_id": _map_by_id(bosses),
		"waves": waves,
		"waves_by_round": _map_waves_by_round(waves),
		"recipes": recipes,
		"difficulties": difficulties,
		"difficulties_by_id": _map_by_id(difficulties),
		"story_boss_stages": story_stages,
		"story_boss_stages_by_stage": _map_by_stage(story_stages),
		"mission_bosses": mission_bosses,
		"mission_bosses_by_id": _map_by_id(mission_bosses),
		"round_draw_rules": round_draw_rules,
		"currencies": currencies,
	}


func _load_json(relative_path: String, expected_key: String) -> Dictionary:
	var file_path: String = _data_root_path().path_join(relative_path)
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		last_error = "Unable to open shared data file: %s" % file_path
		return {}

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		last_error = "Shared data file did not parse as a dictionary: %s" % file_path
		return {}

	var parsed_dict: Dictionary = parsed
	if not parsed_dict.has(expected_key):
		last_error = "Shared data file is missing key '%s': %s" % [expected_key, file_path]
		return {}

	return parsed_dict


func _data_root_path() -> String:
	return ProjectSettings.globalize_path("res://").path_join(DATA_ROOT)


func _resolve_path_tiles(board_data: Dictionary, paths_data: Dictionary) -> Array[Vector2i]:
	var requested_path_id: String = str(board_data.get("path_id", ""))
	var resolved_tiles: Array[Vector2i] = []

	for path_definition: Dictionary in paths_data.get("paths", []):
		if str(path_definition.get("id", "")) != requested_path_id:
			continue

		for tile in path_definition.get("tiles", []):
			if tile is Array and tile.size() >= 2:
				resolved_tiles.append(Vector2i(int(tile[0]), int(tile[1])))
		break

	return resolved_tiles


func _map_by_id(items: Array) -> Dictionary:
	var mapped: Dictionary = {}
	for item in items:
		var item_id: String = str(item.get("id", ""))
		if item_id.is_empty():
			continue
		mapped[item_id] = item
	return mapped


func _map_waves_by_round(waves: Array) -> Dictionary:
	var mapped: Dictionary = {}
	for wave in waves:
		mapped[int(wave.get("round", 0))] = wave
	return mapped


func _map_by_stage(items: Array) -> Dictionary:
	var mapped: Dictionary = {}
	for item in items:
		mapped[int(item.get("stage", 0))] = item
	return mapped


func _collect_common_unit_ids(units: Array) -> Array:
	var common_ids: Array = []
	for unit in units:
		if str(unit.get("rarity", "")) == "common":
			common_ids.append(str(unit.get("id", "")))
	return common_ids


func _collect_unit_ids_by_rarity(units: Array) -> Dictionary:
	var grouped := {
		"common": [],
		"rare": [],
		"unique": [],
		"legendary": [],
	}

	for unit in units:
		var rarity: String = str(unit.get("rarity", ""))
		if grouped.has(rarity):
			grouped[rarity].append(str(unit.get("id", "")))

	return grouped
