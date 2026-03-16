extends RefCounted

class_name RoundRuntime

const ROUND_DURATION_SECONDS := 60
const ACTIVE_SPAWN_SECONDS := 40
const TOTAL_SPAWNS_PER_ROUND := 40


static func create_spawn_schedule(round: int, wave: Dictionary, difficulty: Dictionary) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	var counter: int = 0
	var weighted_enemy_ids: Array[String] = _build_weighted_enemy_ids(wave)
	var boss_id: Variant = wave.get("boss_id", null)
	var boss_id_text: String = "" if boss_id == null else str(boss_id)
	var normal_spawn_count: int = TOTAL_SPAWNS_PER_ROUND

	for spawn_index in range(normal_spawn_count):
		if weighted_enemy_ids.is_empty():
			break

		counter += 1
		events.append({
			"spawn_time_seconds": float(spawn_index),
			"enemy_definition_id": weighted_enemy_ids[spawn_index % weighted_enemy_ids.size()],
			"instance_id": "enemy_%d_%d" % [round, counter],
			"is_boss": false,
		})

	if not boss_id_text.is_empty():
		counter += 1
		events.append({
			"spawn_time_seconds": float(ACTIVE_SPAWN_SECONDS),
			"enemy_definition_id": boss_id_text,
			"instance_id": "enemy_%d_%d" % [round, counter],
			"is_boss": true,
		})

	return events


static func _build_weighted_enemy_ids(wave: Dictionary) -> Array[String]:
	var weighted_enemy_ids: Array[String] = []

	for entry: Dictionary in wave.get("entries", []):
		var enemy_id: String = str(entry.get("enemy_id", ""))
		var count: int = max(1, int(entry.get("count", 0)))
		if enemy_id.is_empty():
			continue

		for _count_index in range(count):
			weighted_enemy_ids.append(enemy_id)

	return weighted_enemy_ids


static func spawn_due_enemies(
	elapsed_seconds: float,
	schedule: Array[Dictionary],
	enemy_definitions: Dictionary,
	boss_definitions: Dictionary,
	difficulty: Dictionary
) -> Array[Dictionary]:
	var spawns: Array[Dictionary] = []

	while not schedule.is_empty():
		var next_event: Dictionary = schedule[0]
		if float(next_event.get("spawn_time_seconds", 0.0)) > elapsed_seconds:
			break

		schedule.remove_at(0)

		var definition_id: String = str(next_event.get("enemy_definition_id", ""))
		var definition: Dictionary = enemy_definitions.get(definition_id, boss_definitions.get(definition_id, {}))
		if definition.is_empty():
			continue

		spawns.append(_create_enemy_runtime(next_event, definition, difficulty))

	return spawns


static func advance_enemies(enemies: Array[Dictionary], delta_seconds: float, path_length: int) -> int:
	if path_length <= 0:
		return 0

	for enemy: Dictionary in enemies:
		enemy["progress_to_next_tile"] = float(enemy.get("progress_to_next_tile", 0.0)) + float(enemy.get("move_speed", 0.0)) * delta_seconds

		while float(enemy.get("progress_to_next_tile", 0.0)) >= 1.0:
			enemy["progress_to_next_tile"] = float(enemy.get("progress_to_next_tile", 0.0)) - 1.0
			var next_index: int = int(enemy.get("path_index", 0)) + 1
			if next_index >= path_length:
				next_index = 0
			enemy["path_index"] = next_index

	return 0


static func _create_enemy_runtime(event: Dictionary, definition: Dictionary, difficulty: Dictionary) -> Dictionary:
	var hp_multiplier: float = float(difficulty.get("enemy_hp_multiplier", 1.0))
	var max_hp: int = int(round(float(definition.get("combat", {}).get("max_hp", 1)) * hp_multiplier))

	return {
		"instance_id": str(event.get("instance_id", "")),
		"definition_id": str(definition.get("id", "")),
		"display_name": str(definition.get("display_name", "")),
		"type": str(definition.get("type", "boss" if bool(event.get("is_boss", false)) else "normal")),
		"is_boss": bool(event.get("is_boss", false)),
		"move_speed": float(definition.get("movement", {}).get("move_speed", 1.0)),
		"armor": float(definition.get("combat", {}).get("armor", 0.0)),
		"magic_resist": float(definition.get("combat", {}).get("magic_resist", 0.0)),
		"reward_gold": 0 if bool(event.get("is_boss", false)) else int(definition.get("reward", {}).get("gold", 0)),
		"max_hp": max_hp,
		"current_hp": max_hp,
		"path_index": 0,
		"progress_to_next_tile": 0.0,
		"defeated": false,
		"leaked": false,
		"hit_flash_remaining": 0.0,
	}
