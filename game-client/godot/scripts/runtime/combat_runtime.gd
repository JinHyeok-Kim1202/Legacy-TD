extends RefCounted

class_name CombatRuntime


static func reset_unit_cooldowns(board_units: Array[Dictionary]) -> void:
	for occupant: Dictionary in board_units:
		occupant["attack_cooldown_remaining"] = 0.0


static func step_combat(board_units: Array[Dictionary], enemies: Array[Dictionary], path_tiles: Array[Vector2i], delta_seconds: float) -> Dictionary:
	var attacks: Array[Dictionary] = []
	var defeated_enemy_ids: Array[String] = []
	var total_gold_earned: int = 0

	for occupant: Dictionary in board_units:
		var unit: Dictionary = occupant.get("unit", {})
		if unit.is_empty():
			continue

		var current_cooldown: float = max(0.0, float(occupant.get("attack_cooldown_remaining", 0.0)) - delta_seconds)
		occupant["attack_cooldown_remaining"] = current_cooldown
		if current_cooldown > 0.0:
			continue

		var target: Variant = _select_target(occupant, enemies, path_tiles)
		if target == null:
			continue

		var attack_result: Dictionary = _resolve_attack(occupant, target)
		var offense: Dictionary = _resolve_unit_offense(unit.get("definition", {}))
		occupant["attack_cooldown_remaining"] = 1.0 / max(0.001, float(offense.get("attack_speed", 1.0)))

		if bool(attack_result.get("target_defeated", false)):
			total_gold_earned += int(target.get("reward_gold", 0))
			defeated_enemy_ids.append(str(target.get("instance_id", "")))

		attacks.append({
			"attacker_id": str(unit.get("instance_id", "")),
			"target_id": str(target.get("instance_id", "")),
			"damage_applied": int(attack_result.get("damage_applied", 0)),
			"was_critical": bool(attack_result.get("was_critical", false)),
			"target_defeated": bool(attack_result.get("target_defeated", false)),
		})

	_prune_defeated_enemies(enemies)

	return {
		"attacks": attacks,
		"defeated_enemy_ids": defeated_enemy_ids,
		"gold_earned": total_gold_earned,
	}


static func _prune_defeated_enemies(enemies: Array[Dictionary]) -> void:
	for index: int in range(enemies.size() - 1, -1, -1):
		var enemy: Dictionary = enemies[index]
		if bool(enemy.get("defeated", false)):
			enemies.remove_at(index)


static func _select_target(occupant: Dictionary, enemies: Array[Dictionary], path_tiles: Array[Vector2i]) -> Variant:
	var unit: Dictionary = occupant.get("unit", {})
	var unit_definition: Dictionary = unit.get("definition", {})
	var attack_profile: Dictionary = unit_definition.get("attack", {})
	var candidates: Array[Dictionary] = []

	for enemy: Dictionary in enemies:
		if bool(enemy.get("defeated", false)) or bool(enemy.get("leaked", false)):
			continue

		var enemy_position: Vector2i = _get_enemy_tile(enemy, path_tiles)
		var unit_position: Vector2i = occupant.get("position", Vector2i.ZERO)
		if _distance_between(unit_position, enemy_position) <= float(attack_profile.get("range", 0.0)):
			candidates.append(enemy)

	if candidates.is_empty():
		return null

	var targeting_mode: String = str(attack_profile.get("targeting", "nearest"))
	var best_target: Dictionary = candidates[0]

	for index: int in range(1, candidates.size()):
		var current: Dictionary = candidates[index]
		if _is_better_target(targeting_mode, occupant, best_target, current, path_tiles):
			best_target = current

	return best_target


static func _is_better_target(targeting_mode: String, occupant: Dictionary, best_target: Dictionary, current_target: Dictionary, path_tiles: Array[Vector2i]) -> bool:
	match targeting_mode:
		"first":
			return int(current_target.get("path_index", 0)) > int(best_target.get("path_index", 0))
		"last":
			return int(current_target.get("path_index", 0)) < int(best_target.get("path_index", 0))
		"strongest":
			return int(current_target.get("current_hp", 0)) > int(best_target.get("current_hp", 0))
		"weakest":
			return int(current_target.get("current_hp", 0)) < int(best_target.get("current_hp", 0))
		_:
			var unit_position: Vector2i = occupant.get("position", Vector2i.ZERO)
			var best_distance: float = _distance_between(unit_position, _get_enemy_tile(best_target, path_tiles))
			var current_distance: float = _distance_between(unit_position, _get_enemy_tile(current_target, path_tiles))
			return current_distance < best_distance


static func _distance_between(a: Vector2i, b: Vector2i) -> float:
	var row_delta: int = a.x - b.x
	var col_delta: int = a.y - b.y
	return sqrt(float(row_delta * row_delta + col_delta * col_delta))


static func _get_enemy_tile(enemy: Dictionary, path_tiles: Array[Vector2i]) -> Vector2i:
	if path_tiles.is_empty():
		return Vector2i.ZERO

	var enemy_index: int = clamp(int(enemy.get("path_index", 0)), 0, path_tiles.size() - 1)
	return path_tiles[enemy_index]


static func _resolve_attack(occupant: Dictionary, target: Dictionary) -> Dictionary:
	var unit: Dictionary = occupant.get("unit", {})
	var unit_definition: Dictionary = unit.get("definition", {})
	var attack_profile: Dictionary = unit_definition.get("attack", {})
	var offense: Dictionary = _resolve_unit_offense(unit_definition)
	var was_critical: bool = randf() <= float(offense.get("crit_chance", 0.0))

	var raw_damage: float = 0.0
	if str(attack_profile.get("damage_type", "physical")) == "physical":
		raw_damage = float(offense.get("physical_damage", 0.0)) - float(target.get("armor", 0.0))
	else:
		raw_damage = float(offense.get("magic_damage", 0.0)) * (1.0 - float(target.get("magic_resist", 0.0)))

	var critical_multiplier: float = float(attack_profile.get("crit_multiplier", 1.0)) if was_critical else 1.0
	var damage_applied: int = maxi(1, int(round(raw_damage * critical_multiplier)))
	var next_hp: int = maxi(0, int(target.get("current_hp", 0)) - damage_applied)

	target["current_hp"] = next_hp
	target["defeated"] = next_hp <= 0
	target["hit_flash_remaining"] = 0.12

	return {
		"damage_applied": damage_applied,
		"was_critical": was_critical,
		"target_defeated": bool(target.get("defeated", false)),
	}


static func _resolve_unit_offense(unit_definition: Dictionary) -> Dictionary:
	var attack_profile: Dictionary = unit_definition.get("attack", {})
	var stats: Dictionary = unit_definition.get("stats", {})
	var scaling: Dictionary = unit_definition.get("scaling", {})
	var damage_type: String = str(attack_profile.get("damage_type", "physical"))

	return {
		"physical_damage": float(attack_profile.get("base_damage", 0.0)) + float(stats.get("strength", 0.0)) * float(scaling.get("strength_to_physical_damage", 0.0)) if damage_type == "physical" else 0.0,
		"magic_damage": float(attack_profile.get("base_damage", 0.0)) + float(stats.get("intelligence", 0.0)) * float(scaling.get("intelligence_to_magic_damage", 0.0)) if damage_type == "magic" else 0.0,
		"attack_speed": float(attack_profile.get("attack_speed", 1.0)) + float(stats.get("agility", 0.0)) * float(scaling.get("agility_to_attack_speed", 0.0)),
		"crit_chance": float(attack_profile.get("crit_chance", 0.0)) + float(stats.get("agility", 0.0)) * float(scaling.get("agility_to_crit_chance", 0.0)),
	}
