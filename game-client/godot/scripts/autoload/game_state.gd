extends Node

signal data_loaded
signal storage_changed
signal board_changed
signal enemies_changed
signal round_state_changed
signal selection_changed

const SharedDataLoader = preload("res://scripts/runtime/shared_data_loader.gd")
const RoundRuntime = preload("res://scripts/runtime/round_runtime.gd")
const CombatRuntime = preload("res://scripts/runtime/combat_runtime.gd")
const MergeRuntime = preload("res://scripts/runtime/merge_runtime.gd")
const DebugLogger = preload("res://scripts/runtime/debug_logger.gd")
const ROUND_INTERVAL_SECONDS := 60.0
const INITIAL_ROUND_DELAY_SECONDS := 30.0
const STORY_SLOT_COUNT := 3

const BOARD_ROWS := 7
const BOARD_COLS := 7
const STORAGE_CAPACITY := 20
const SHOP_RANDOM_DRAW_COST := 30
const SHOP_RANDOM_DRAW_RARE_CHANCE := 0.15
const SHOP_TARGETED_DRAW_COSTS := {
	"common": 140,
	"rare": 420,
	"unique": 1260,
}
const FORGE_UPGRADE_DEFINITIONS := [
	{"id": "strength_stat", "label": "힘 스텟 강화", "base_cost": 60.0, "growth": 24.0},
	{"id": "agility_stat", "label": "민첩 스텟 강화", "base_cost": 60.0, "growth": 24.0},
	{"id": "intelligence_stat", "label": "지능 스텟 강화", "base_cost": 60.0, "growth": 24.0},
	{"id": "physical_damage", "label": "물리 피해량 강화", "base_cost": 90.0, "growth": 32.0},
	{"id": "attack_speed", "label": "공격속도 강화", "base_cost": 90.0, "growth": 28.0},
	{"id": "magic_damage", "label": "마법 피해량 강화", "base_cost": 90.0, "growth": 32.0},
	{"id": "common_damage", "label": "커먼 등급 피해량 업그레이드", "base_cost": 70.0, "growth": 26.0},
	{"id": "rare_damage", "label": "레어 등급 피해량 업그레이드", "base_cost": 100.0, "growth": 36.0},
	{"id": "unique_damage", "label": "유니크 등급 피해량 업그레이드", "base_cost": 150.0, "growth": 48.0},
	{"id": "legendary_damage", "label": "레전더리 등급 피해량 업그레이드", "base_cost": 220.0, "growth": 66.0},
	{"id": "transcendent_damage", "label": "초월자 등급 피해량 업그레이드", "base_cost": 320.0, "growth": 92.0},
	{"id": "immortal_damage", "label": "불멸자 등급 피해량 업그레이드", "base_cost": 460.0, "growth": 128.0},
	{"id": "god_damage", "label": "신 등급 피해량 업그레이드", "base_cost": 640.0, "growth": 170.0},
	{"id": "liberator_damage", "label": "해방자 등급 피해량 업그레이드", "base_cost": 880.0, "growth": 220.0},
]

var current_round: int = 0
var leaked_enemy_count: int = 0
var current_gold: int = 0
var storage_count: int = 0
var storage_capacity: int = STORAGE_CAPACITY
var board_rows: int = BOARD_ROWS
var board_cols: int = BOARD_COLS
var path_tiles: Array[Vector2i] = []
var selected_storage_index: int = -1
var selected_board_unit_instance_id: String = ""
var selected_story_slot_index: int = -1
var round_active: bool = false
var round_elapsed_seconds: float = 0.0
var pending_spawn_count: int = 0
var next_round_number: int = 1
var seconds_until_next_round: float = ROUND_INTERVAL_SECONDS
var defeated_enemy_count_this_round: int = 0
var total_attack_count_this_round: int = 0
var round_gold_earned: int = 0
var recent_draw_units: Array[Dictionary] = []
var status_message: String = "Loading shared data..."
var last_error: String = ""
var difficulty_id: String = "easy"
var difficulty_selected: bool = false
var game_over: bool = false
var game_over_reason: String = ""
var story_boss_stage: int = 1
var story_boss_completed: bool = false
var story_boss_current_hp: int = 0
var current_mission_boss: Dictionary = {}

var _definitions: Dictionary = {}
var _storage_slots: Array[Dictionary] = []
var _board_units: Array[Dictionary] = []
var _story_slots: Array[Dictionary] = []
var _active_enemies: Array[Dictionary] = []
var _spawn_schedule: Array[Dictionary] = []
var _active_round_spawners: Array[Dictionary] = []
var _mission_boss_states: Array[Dictionary] = []
var _unit_instance_counter: int = 0
var _draw_cursor: int = 0
var _rng := RandomNumberGenerator.new()
var _forge_upgrade_levels: Dictionary = {}


func initialize() -> bool:
	var loader: SharedDataLoader = SharedDataLoader.new()
	_definitions = loader.load_all()

	if _definitions.is_empty():
		last_error = loader.last_error
		status_message = last_error
		_log_debug("initialize_failed", {
			"last_error": last_error,
		})
		data_loaded.emit()
		round_state_changed.emit()
		return false

	_rng.randomize()
	_reset_runtime()
	_log_debug("session_started", {
		"log_path": DebugLogger.get_log_path(),
		"board_rows": board_rows,
		"board_cols": board_cols,
	})
	data_loaded.emit()
	return true


func has_loaded_data() -> bool:
	return not _definitions.is_empty()


func has_wave_for_current_round() -> bool:
	return has_loaded_data() and current_round < 60


func get_difficulties() -> Array:
	return _definitions.get("difficulties", [])


func get_current_active_enemy_limit() -> int:
	var difficulty: Dictionary = _get_current_difficulty()
	return int(difficulty.get("max_active_enemies", difficulty.get("max_leaked_enemies", 999999)))


func get_round_label_text() -> String:
	if not difficulty_selected:
		return "Round waiting"
	if current_round <= 0:
		return "Round %d incoming" % next_round_number
	return "Round %d" % current_round


func get_next_round_timer_text() -> String:
	if not difficulty_selected:
		return "Choose a difficulty to begin"
	return "Next round in %ds" % int(ceil(seconds_until_next_round))


func get_next_round_countdown_seconds() -> int:
	return int(max(0.0, ceil(seconds_until_next_round)))


func get_field_enemy_warning_text() -> String:
	return "FIELD ENEMIES %d / %d" % [_active_enemies.size(), get_current_active_enemy_limit()]


func is_field_enemy_warning_active() -> bool:
	if not difficulty_selected:
		return false
	var limit: int = get_current_active_enemy_limit()
	if limit <= 0:
		return false
	return float(_active_enemies.size()) / float(limit) >= 0.8


func get_upcoming_boss_warning_text() -> String:
	if not is_upcoming_boss_round():
		return ""

	var wave: Dictionary = _definitions.get("waves_by_round", {}).get(next_round_number, {})
	var boss_id_value: Variant = wave.get("boss_id", null)
	var boss_id: String = "" if boss_id_value == null else str(boss_id_value)
	var boss_definition: Dictionary = _definitions.get("bosses_by_id", {}).get(boss_id, {})
	var boss_name: String = str(boss_definition.get("display_name", "Boss"))
	return "BOSS INCOMING: %s" % boss_name


func is_upcoming_boss_round() -> bool:
	if not difficulty_selected:
		return false
	if next_round_number <= 1:
		return false
	if get_next_round_countdown_seconds() > 5:
		return false

	var wave: Dictionary = _definitions.get("waves_by_round", {}).get(next_round_number, {})
	var boss_id_value: Variant = wave.get("boss_id", null)
	return not wave.is_empty() and boss_id_value != null and str(boss_id_value) != ""


func get_unit_display_name(definition_id: String) -> String:
	var definition: Dictionary = _definitions.get("units_by_id", {}).get(definition_id, {})
	return str(definition.get("display_name", definition_id))


func get_story_slots() -> Array[Dictionary]:
	return _story_slots.duplicate(true)


func get_selected_story_unit() -> Dictionary:
	if selected_story_slot_index < 0 or selected_story_slot_index >= _story_slots.size():
		return {}

	var unit: Variant = _story_slots[selected_story_slot_index].get("unit")
	return unit if unit != null else {}


func get_story_boss_state() -> Dictionary:
	var stage_definition: Dictionary = _definitions.get("story_boss_stages_by_stage", {}).get(story_boss_stage, {})
	return {
		"stage": story_boss_stage,
		"completed": story_boss_completed,
		"display_name": str(stage_definition.get("display_name", "Story Boss")),
		"current_hp": story_boss_current_hp,
		"max_hp": int(stage_definition.get("max_hp", 1)),
		"armor": float(stage_definition.get("armor", 0.0)),
		"magic_resist": float(stage_definition.get("magic_resist", 0.0)),
	}


func get_mission_boss_states() -> Array[Dictionary]:
	return _mission_boss_states.duplicate(true)


func get_merge_recipe_options() -> Array[Dictionary]:
	var anchor_unit: Dictionary = get_selected_anchor_unit()
	if anchor_unit.is_empty():
		return []

	var anchor_definition_id: String = str(anchor_unit.get("definition_id", ""))
	var recipes: Array = _definitions.get("recipes", [])
	return MergeRuntime.get_recipe_options_for_anchor(recipes, _storage_slots, _board_units, _story_slots, anchor_definition_id)


func get_storage_slots() -> Array[Dictionary]:
	return _storage_slots.duplicate(true)


func get_storage_groups() -> Array[Dictionary]:
	var grouped: Dictionary = {}
	var ordered_groups: Array[Dictionary] = []

	for slot: Dictionary in _storage_slots:
		var unit: Variant = slot.get("unit")
		if unit == null:
			continue

		var definition_id: String = str(unit.get("definition_id", ""))
		if not grouped.has(definition_id):
			var group := {
				"definition_id": definition_id,
				"display_name": str(unit.get("display_name", "Unit")),
				"rarity": str(unit.get("rarity", "common")),
				"count": 0,
				"instance_ids": [],
				"representative_instance_id": str(unit.get("instance_id", "")),
				"representative_unit": unit.duplicate(true),
			}
			grouped[definition_id] = group
			ordered_groups.append(group)

		var existing_group: Dictionary = grouped[definition_id]
		existing_group["count"] = int(existing_group.get("count", 0)) + 1
		var instance_ids: Array = existing_group.get("instance_ids", [])
		instance_ids.append(str(unit.get("instance_id", "")))
		existing_group["instance_ids"] = instance_ids

	return ordered_groups


func get_board_units() -> Array[Dictionary]:
	return _board_units.duplicate(true)


func get_active_enemies() -> Array[Dictionary]:
	return _active_enemies.duplicate(true)


func get_selected_board_unit() -> Dictionary:
	if selected_board_unit_instance_id.is_empty():
		return {}

	for occupant: Dictionary in _board_units:
		var unit: Dictionary = occupant.get("unit", {})
		if str(unit.get("instance_id", "")) == selected_board_unit_instance_id:
			return occupant.duplicate(true)

	return {}


func get_selected_anchor_unit() -> Dictionary:
	var selected_storage_unit: Dictionary = get_selected_storage_unit()
	if not selected_storage_unit.is_empty():
		return selected_storage_unit

	var selected_board_occupant: Dictionary = get_selected_board_unit()
	if not selected_board_occupant.is_empty():
		return selected_board_occupant.get("unit", {})

	var selected_story_unit: Dictionary = get_selected_story_unit()
	if not selected_story_unit.is_empty():
		return selected_story_unit

	return {}


func get_selected_unit() -> Dictionary:
	var selected_storage_unit: Dictionary = get_selected_storage_unit()
	if not selected_storage_unit.is_empty():
		return selected_storage_unit

	var selected_board_unit: Dictionary = get_selected_board_unit()
	if not selected_board_unit.is_empty():
		return selected_board_unit.get("unit", {})

	var selected_story_unit: Dictionary = get_selected_story_unit()
	if not selected_story_unit.is_empty():
		return selected_story_unit

	return {}


func has_storage_space() -> bool:
	return true


func get_owned_unit_counts() -> Dictionary:
	var counts: Dictionary = {}

	for slot: Dictionary in _storage_slots:
		var storage_unit: Variant = slot.get("unit")
		if storage_unit == null:
			continue
		var storage_definition_id: String = str(storage_unit.get("definition_id", ""))
		counts[storage_definition_id] = int(counts.get(storage_definition_id, 0)) + 1

	for occupant: Dictionary in _board_units:
		var board_unit: Dictionary = occupant.get("unit", {})
		var board_definition_id: String = str(board_unit.get("definition_id", ""))
		counts[board_definition_id] = int(counts.get(board_definition_id, 0)) + 1

	for story_slot: Dictionary in _story_slots:
		var story_unit: Variant = story_slot.get("unit")
		if story_unit == null:
			continue
		var story_definition_id: String = str(story_unit.get("definition_id", ""))
		counts[story_definition_id] = int(counts.get(story_definition_id, 0)) + 1

	return counts


func get_unit_rarity(definition_id: String) -> String:
	var definition: Dictionary = _definitions.get("units_by_id", {}).get(definition_id, {})
	return str(definition.get("rarity", ""))


func get_recipe_by_id(recipe_id: String) -> Dictionary:
	return _find_recipe_by_id(recipe_id)


func get_recipe_browser_entries(rarity: String, filter_output_ids: Array[String] = []) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	var filter_lookup: Dictionary = {}
	for output_id: String in filter_output_ids:
		filter_lookup[output_id] = true

	for recipe: Dictionary in _definitions.get("recipes", []):
		var output_unit_id: String = str(recipe.get("output_unit_id", ""))
		var output_definition: Dictionary = _definitions.get("units_by_id", {}).get(output_unit_id, {})
		if output_definition.is_empty():
			continue
		if str(output_definition.get("rarity", "")) != rarity:
			continue
		if not filter_lookup.is_empty() and not filter_lookup.has(output_unit_id):
			continue

		var entry := recipe.duplicate(true)
		entry["output_display_name"] = str(output_definition.get("display_name", output_unit_id))
		entries.append(entry)

	entries.sort_custom(func(a: Dictionary, b: Dictionary): return str(a.get("output_display_name", "")) < str(b.get("output_display_name", "")))
	return entries


func get_recipes_for_output_unit(output_unit_id: String) -> Array[Dictionary]:
	var matches: Array[Dictionary] = []
	for recipe: Dictionary in _definitions.get("recipes", []):
		if str(recipe.get("output_unit_id", "")) == output_unit_id:
			matches.append(recipe.duplicate(true))
	return matches


func get_recipes_using_unit(unit_id: String) -> Array[Dictionary]:
	var matches: Array[Dictionary] = []
	for recipe: Dictionary in _definitions.get("recipes", []):
		for input: Dictionary in recipe.get("inputs", []):
			if str(input.get("unit_id", "")) != unit_id:
				continue
			var entry: Dictionary = recipe.duplicate(true)
			var output_unit_id: String = str(entry.get("output_unit_id", ""))
			var output_definition: Dictionary = _definitions.get("units_by_id", {}).get(output_unit_id, {})
			entry["output_display_name"] = str(output_definition.get("display_name", output_unit_id))
			matches.append(entry)
			break
	return matches


func get_unit_definition(definition_id: String) -> Dictionary:
	return _definitions.get("units_by_id", {}).get(definition_id, {}).duplicate(true)


func get_shop_random_draw_cost() -> int:
	return SHOP_RANDOM_DRAW_COST


func get_shop_targeted_draw_cost(rarity: String) -> int:
	return int(SHOP_TARGETED_DRAW_COSTS.get(rarity, 0))


func get_shop_units_by_rarity(rarity: String) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for unit_id: Variant in _definitions.get("unit_ids_by_rarity", {}).get(rarity, []):
		var definition: Dictionary = _definitions.get("units_by_id", {}).get(str(unit_id), {})
		if definition.is_empty():
			continue
		entries.append({
			"definition_id": str(definition.get("id", "")),
			"display_name": str(definition.get("display_name", "")),
			"rarity": str(definition.get("rarity", rarity)),
			"definition": definition.duplicate(true),
		})
	entries.sort_custom(func(a: Dictionary, b: Dictionary): return str(a.get("display_name", "")) < str(b.get("display_name", "")))
	return entries


func purchase_random_draw() -> bool:
	if current_gold < SHOP_RANDOM_DRAW_COST:
		status_message = "골드가 부족합니다."
		round_state_changed.emit()
		return false

	var rarity: String = "rare" if _rng.randf() < SHOP_RANDOM_DRAW_RARE_CHANCE else "common"
	current_gold -= SHOP_RANDOM_DRAW_COST
	var drawn_count: int = _draw_units_by_rarity(rarity, 1, true)
	if drawn_count <= 0:
		current_gold += SHOP_RANDOM_DRAW_COST
		status_message = "뽑기에 실패했습니다."
		round_state_changed.emit()
		return false

	var drawn_unit: Dictionary = recent_draw_units[0] if not recent_draw_units.is_empty() else {}
	status_message = "%s 뽑기 성공" % str(drawn_unit.get("display_name", rarity))
	_log_debug("shop_random_draw", {
		"rarity": rarity,
		"cost": SHOP_RANDOM_DRAW_COST,
		"unit_id": str(drawn_unit.get("definition_id", "")),
	})
	storage_changed.emit()
	round_state_changed.emit()
	return true


func purchase_targeted_draw(unit_id: String) -> bool:
	var definition: Dictionary = _definitions.get("units_by_id", {}).get(unit_id, {})
	if definition.is_empty():
		status_message = "해당 등급은 선택 뽑기를 지원하지 않습니다."
		round_state_changed.emit()
		return false

	var rarity: String = str(definition.get("rarity", ""))
	var cost: int = get_shop_targeted_draw_cost(rarity)
	if cost <= 0:
		status_message = "해당 등급은 선택 뽑기를 지원하지 않습니다."
		round_state_changed.emit()
		return false
	if current_gold < cost:
		status_message = "골드가 부족합니다."
		round_state_changed.emit()
		return false

	current_gold -= cost
	if not _draw_specific_unit(unit_id, true):
		current_gold += cost
		status_message = "선택 뽑기에 실패했습니다."
		round_state_changed.emit()
		return false

	status_message = "%s 선택 뽑기 성공" % str(definition.get("display_name", unit_id))
	_log_debug("shop_targeted_draw", {
		"rarity": rarity,
		"cost": cost,
		"unit_id": unit_id,
	})
	storage_changed.emit()
	round_state_changed.emit()
	return true


func get_forge_upgrade_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for definition: Dictionary in FORGE_UPGRADE_DEFINITIONS:
		var entry: Dictionary = definition.duplicate(true)
		var upgrade_id: String = str(entry.get("id", ""))
		entry["level"] = get_forge_upgrade_level(upgrade_id)
		entry["cost"] = get_forge_upgrade_cost(upgrade_id)
		entries.append(entry)
	return entries


func get_forge_upgrade_level(upgrade_id: String) -> int:
	return int(_forge_upgrade_levels.get(upgrade_id, 0))


func get_forge_upgrade_cost(upgrade_id: String) -> int:
	for definition: Dictionary in FORGE_UPGRADE_DEFINITIONS:
		if str(definition.get("id", "")) != upgrade_id:
			continue
		var level: int = get_forge_upgrade_level(upgrade_id)
		var base_cost: float = float(definition.get("base_cost", 0.0))
		var growth: float = float(definition.get("growth", 0.0))
		var scaled_cost: float = base_cost + growth * float(level) * log(float(level) + 2.0)
		return int(round(scaled_cost))
	return 0


func purchase_forge_upgrade(upgrade_id: String) -> bool:
	var cost: int = get_forge_upgrade_cost(upgrade_id)
	if cost <= 0:
		status_message = "해당 강화는 사용할 수 없습니다."
		round_state_changed.emit()
		return false
	if current_gold < cost:
		status_message = "골드가 부족합니다."
		round_state_changed.emit()
		return false

	current_gold -= cost
	_forge_upgrade_levels[upgrade_id] = get_forge_upgrade_level(upgrade_id) + 1
	status_message = "%s Lv.%d" % [_get_forge_upgrade_label(upgrade_id), get_forge_upgrade_level(upgrade_id)]
	_log_debug("forge_upgrade", {
		"upgrade_id": upgrade_id,
		"level": get_forge_upgrade_level(upgrade_id),
		"cost": cost,
	})
	selection_changed.emit()
	round_state_changed.emit()
	return true


func get_unit_combat_snapshot(unit_or_definition: Dictionary) -> Dictionary:
	var definition: Dictionary = unit_or_definition.get("definition", unit_or_definition)
	var stats: Dictionary = definition.get("stats", {})
	var attack: Dictionary = definition.get("attack", {})
	var scaling: Dictionary = definition.get("scaling", {})
	var rarity: String = str(definition.get("rarity", "common"))
	var damage_type: String = str(attack.get("damage_type", "physical"))
	var strength: int = int(stats.get("strength", 0)) + get_forge_upgrade_level("strength_stat")
	var agility: int = int(stats.get("agility", 0)) + get_forge_upgrade_level("agility_stat")
	var intelligence: int = int(stats.get("intelligence", 0)) + get_forge_upgrade_level("intelligence_stat")
	var damage_multiplier: float = 1.0 + float(get_forge_upgrade_level("%s_damage" % rarity)) * 0.05
	var damage_value: float = float(attack.get("base_damage", 0.0))
	if damage_type == "physical":
		damage_value += float(get_forge_upgrade_level("physical_damage")) * 2.0
		damage_value += float(strength) * float(scaling.get("strength_to_physical_damage", 0.0))
	else:
		damage_value += float(get_forge_upgrade_level("magic_damage")) * 2.0
		damage_value += float(intelligence) * float(scaling.get("intelligence_to_magic_damage", 0.0))
	damage_value *= damage_multiplier
	var attack_speed: float = float(attack.get("attack_speed", 1.0)) + float(agility) * float(scaling.get("agility_to_attack_speed", 0.0)) + float(get_forge_upgrade_level("attack_speed")) * 0.05
	return {
		"rarity": rarity,
		"damage_type": damage_type,
		"strength": strength,
		"agility": agility,
		"intelligence": intelligence,
		"damage": damage_value,
		"attack_speed": attack_speed,
	}


func place_selected_unit_to_story_slot(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= _story_slots.size():
		status_message = "That story slot does not exist."
		_log_debug("action_failed", {
			"action": "place_unit_to_story",
			"reason": status_message,
			"story_slot_index": slot_index,
		})
		round_state_changed.emit()
		return false

	var story_slot: Dictionary = _story_slots[slot_index]
	var selected_source: String = _get_selected_unit_source()
	if selected_source.is_empty():
		if story_slot.get("unit") == null:
			status_message = "Select a unit before placing it into the story lane."
			_log_debug("action_failed", {
				"action": "place_unit_to_story",
				"reason": status_message,
				"story_slot_index": slot_index,
			})
			round_state_changed.emit()
			return false

		select_story_slot(slot_index)
		return true

	if story_slot.get("unit") != null:
		if selected_source == "story" and selected_story_slot_index == slot_index:
			select_story_slot(slot_index)
			return true

		if _swap_selected_unit_with_story_slot(slot_index):
			return true

		status_message = "That story slot is already occupied."
		_log_debug("action_failed", {
			"action": "place_unit_to_story",
			"reason": status_message,
			"story_slot_index": slot_index,
		})
		round_state_changed.emit()
		return false

	var consumed: Dictionary = _take_selected_unit()
	if consumed.is_empty():
		status_message = "The selected unit is no longer available."
		_log_debug("action_failed", {
			"action": "place_unit_to_story",
			"reason": status_message,
			"story_slot_index": slot_index,
		})
		selection_changed.emit()
		round_state_changed.emit()
		return false

	var unit: Dictionary = consumed.get("unit", {})
	story_slot["unit"] = unit
	story_slot["attack_cooldown_remaining"] = 0.0
	selected_story_slot_index = slot_index
	_recalculate_storage_count()
	status_message = "Placed %s into story slot %d." % [str(unit.get("display_name", "Unit")), slot_index + 1]
	_log_debug("unit_moved", {
		"from": selected_source,
		"to": "story",
		"story_slot_index": slot_index,
		"instance_id": str(unit.get("instance_id", "")),
		"definition_id": str(unit.get("definition_id", "")),
		"display_name": str(unit.get("display_name", "Unit")),
	})
	storage_changed.emit()
	board_changed.emit()
	selection_changed.emit()
	round_state_changed.emit()
	return true


func summon_mission_boss(mission_id: String) -> bool:
	for mission_state: Dictionary in _mission_boss_states:
		if str(mission_state.get("id", "")) != mission_id:
			continue

		if not bool(mission_state.get("unlocked", false)):
			status_message = "That mission boss has not been unlocked yet."
			_log_debug("action_failed", {
				"action": "summon_mission_boss",
				"mission_id": mission_id,
				"reason": status_message,
			})
			round_state_changed.emit()
			return false

		if float(mission_state.get("cooldown_remaining", 0.0)) > 0.0:
			status_message = "Mission boss cooldown is still active."
			_log_debug("action_failed", {
				"action": "summon_mission_boss",
				"mission_id": mission_id,
				"reason": status_message,
				"cooldown_remaining": float(mission_state.get("cooldown_remaining", 0.0)),
			})
			round_state_changed.emit()
			return false

		var mission_definition: Dictionary = _definitions.get("mission_bosses_by_id", {}).get(mission_id, {})
		var boss_definition: Dictionary = _definitions.get("bosses_by_id", {}).get(str(mission_definition.get("boss_definition_id", "")), {})
		if boss_definition.is_empty():
			status_message = "Mission boss definition is missing."
			_log_debug("action_failed", {
				"action": "summon_mission_boss",
				"mission_id": mission_id,
				"reason": status_message,
			})
			round_state_changed.emit()
			return false

		var difficulty: Dictionary = _get_current_difficulty()
		var max_hp: int = int(round(float(boss_definition.get("combat", {}).get("max_hp", 1)) * float(difficulty.get("enemy_hp_multiplier", 1.0))))
		current_mission_boss = {
			"id": mission_id,
			"display_name": str(mission_definition.get("display_name", "Mission Boss")),
			"boss_definition_id": str(mission_definition.get("boss_definition_id", "")),
			"instance_id": "mission_%s" % mission_id,
			"current_hp": max_hp,
			"max_hp": max_hp,
			"armor": float(boss_definition.get("combat", {}).get("armor", 0.0)),
			"magic_resist": float(boss_definition.get("combat", {}).get("magic_resist", 0.0)),
		}
		_active_enemies.append({
			"instance_id": str(current_mission_boss.get("instance_id", "")),
			"definition_id": str(boss_definition.get("id", "")),
			"display_name": str(current_mission_boss.get("display_name", "Mission Boss")),
			"type": "boss",
			"is_boss": true,
			"is_mission_boss": true,
			"mission_id": mission_id,
			"move_speed": float(boss_definition.get("movement", {}).get("move_speed", 1.0)),
			"armor": float(boss_definition.get("combat", {}).get("armor", 0.0)),
			"magic_resist": float(boss_definition.get("combat", {}).get("magic_resist", 0.0)),
			"reward_gold": 0,
			"max_hp": max_hp,
			"current_hp": max_hp,
			"path_index": 0,
			"progress_to_next_tile": 0.0,
			"defeated": false,
			"leaked": false,
			"hit_flash_remaining": 0.0,
		})
		_refresh_round_active_state()
		enemies_changed.emit()
		status_message = "%s summoned." % str(current_mission_boss.get("display_name", "Mission Boss"))
		_log_debug("mission_boss_summoned", {
			"mission_id": mission_id,
			"instance_id": str(current_mission_boss.get("instance_id", "")),
			"boss_definition_id": str(current_mission_boss.get("boss_definition_id", "")),
			"display_name": str(current_mission_boss.get("display_name", "Mission Boss")),
			"location": _describe_unit_location(str(current_mission_boss.get("instance_id", ""))),
		})
		round_state_changed.emit()
		return true

	status_message = "Mission boss could not be summoned."
	_log_debug("action_failed", {
		"action": "summon_mission_boss",
		"mission_id": mission_id,
		"reason": status_message,
	})
	round_state_changed.emit()
	return false


func get_selected_storage_unit() -> Dictionary:
	if selected_storage_index < 0 or selected_storage_index >= _storage_slots.size():
		return {}

	var slot: Dictionary = _storage_slots[selected_storage_index]
	var unit: Variant = slot.get("unit")
	return unit if unit != null else {}


func select_storage_slot(index: int) -> void:
	if index < 0 or index >= _storage_slots.size():
		selected_storage_index = -1
		selected_board_unit_instance_id = ""
		selected_story_slot_index = -1
		status_message = "Selection cleared."
		_log_debug("selection_cleared", {
			"source": "storage",
		})
		selection_changed.emit()
		round_state_changed.emit()
		return

	var slot: Dictionary = _storage_slots[index]
	var unit: Variant = slot.get("unit")
	if unit == null:
		selected_storage_index = -1
		selected_board_unit_instance_id = ""
		selected_story_slot_index = -1
		status_message = "That storage slot is empty."
	elif selected_storage_index == index:
		selected_storage_index = -1
		selected_board_unit_instance_id = ""
		selected_story_slot_index = -1
		status_message = "Selection cleared."
		_log_debug("selection_cleared", {
			"source": "storage",
			"slot_index": index,
		})
	else:
		selected_storage_index = index
		selected_board_unit_instance_id = ""
		selected_story_slot_index = -1
		status_message = "Selected %s. Click a board tile to place it." % str(unit.get("display_name", "Unit"))
		_log_debug("unit_selected", {
			"source": "storage",
			"slot_index": index,
			"instance_id": str(unit.get("instance_id", "")),
			"definition_id": str(unit.get("definition_id", "")),
			"display_name": str(unit.get("display_name", "Unit")),
		})

	selection_changed.emit()
	round_state_changed.emit()


func select_storage_unit_by_instance(instance_id: String) -> void:
	for index in range(_storage_slots.size()):
		var slot: Dictionary = _storage_slots[index]
		var unit: Variant = slot.get("unit")
		if unit != null and str(unit.get("instance_id", "")) == instance_id:
			select_storage_slot(index)
			return

	selected_storage_index = -1
	selected_board_unit_instance_id = ""
	selected_story_slot_index = -1
	status_message = "That drawn unit is no longer in storage."
	selection_changed.emit()
	round_state_changed.emit()


func select_board_unit(instance_id: String) -> void:
	if selected_board_unit_instance_id == instance_id:
		selected_storage_index = -1
		selected_board_unit_instance_id = ""
		selected_story_slot_index = -1
		status_message = "Selection cleared."
		_log_debug("selection_cleared", {
			"source": "board",
			"instance_id": instance_id,
		})
		selection_changed.emit()
		round_state_changed.emit()
		return

	selected_storage_index = -1
	selected_board_unit_instance_id = ""
	selected_story_slot_index = -1

	for occupant: Dictionary in _board_units:
		var unit: Dictionary = occupant.get("unit", {})
		if str(unit.get("instance_id", "")) == instance_id:
			selected_board_unit_instance_id = instance_id
			var attack_profile: Dictionary = unit.get("definition", {}).get("attack", {})
			status_message = "%s range %.1f selected." % [
				str(unit.get("display_name", "Unit")),
				float(attack_profile.get("range", 0.0)),
			]
			_log_debug("unit_selected", {
				"source": "board",
				"instance_id": instance_id,
				"definition_id": str(unit.get("definition_id", "")),
				"display_name": str(unit.get("display_name", "Unit")),
				"position": _vector_to_array(occupant.get("position", Vector2i.ZERO)),
			})
			selection_changed.emit()
			round_state_changed.emit()
			return

	status_message = "That unit is no longer on the board."
	selection_changed.emit()
	round_state_changed.emit()


func select_story_slot(slot_index: int) -> void:
	if selected_story_slot_index == slot_index:
		selected_storage_index = -1
		selected_board_unit_instance_id = ""
		selected_story_slot_index = -1
		status_message = "Selection cleared."
		_log_debug("selection_cleared", {
			"source": "story",
			"slot_index": slot_index,
		})
		selection_changed.emit()
		round_state_changed.emit()
		return

	selected_storage_index = -1
	selected_board_unit_instance_id = ""
	selected_story_slot_index = -1

	if slot_index < 0 or slot_index >= _story_slots.size():
		status_message = "Story selection cleared."
		selection_changed.emit()
		round_state_changed.emit()
		return

	var slot: Dictionary = _story_slots[slot_index]
	var unit: Variant = slot.get("unit")
	if unit == null:
		status_message = "That story slot is empty."
	else:
		selected_story_slot_index = slot_index
		status_message = "Selected %s from story slot %d." % [str(unit.get("display_name", "Unit")), slot_index + 1]
		_log_debug("unit_selected", {
			"source": "story",
			"slot_index": slot_index,
			"instance_id": str(unit.get("instance_id", "")),
			"definition_id": str(unit.get("definition_id", "")),
			"display_name": str(unit.get("display_name", "Unit")),
		})

	selection_changed.emit()
	round_state_changed.emit()


func move_selected_unit_to_storage() -> bool:
	var empty_slot_index: int = _find_first_empty_storage_slot()
	var selected_source: String = _get_selected_unit_source()
	if selected_source != "board" and selected_source != "story":
		status_message = "Select a board or story unit first."
		_log_debug("action_failed", {
			"action": "move_to_storage",
			"reason": status_message,
		})
		round_state_changed.emit()
		return false

	var consumed: Dictionary = _take_selected_unit()
	if consumed.is_empty():
		status_message = "The selected unit is no longer available."
		_log_debug("action_failed", {
			"action": "move_to_storage",
			"reason": status_message,
		})
		selection_changed.emit()
		round_state_changed.emit()
		return false

	var unit: Dictionary = consumed.get("unit", {})
	_storage_slots[empty_slot_index]["unit"] = unit
	selected_storage_index = empty_slot_index
	_recalculate_storage_count()
	status_message = "Moved %s to storage." % str(unit.get("display_name", "Unit"))
	_log_debug("unit_moved", {
		"from": selected_source,
		"to": "storage",
		"storage_slot_index": empty_slot_index,
		"instance_id": str(unit.get("instance_id", "")),
		"definition_id": str(unit.get("definition_id", "")),
		"display_name": str(unit.get("display_name", "Unit")),
	})
	storage_changed.emit()
	board_changed.emit()
	selection_changed.emit()
	round_state_changed.emit()
	return true


func _swap_selected_unit_with_story_slot(story_slot_index: int) -> bool:
	if story_slot_index < 0 or story_slot_index >= _story_slots.size():
		return false

	var target_slot: Dictionary = _story_slots[story_slot_index]
	var target_unit: Variant = target_slot.get("unit")
	if target_unit == null:
		return false

	var selected_source: String = _get_selected_unit_source()
	match selected_source:
		"storage":
			if selected_storage_index < 0 or selected_storage_index >= _storage_slots.size():
				return false
			var storage_slot: Dictionary = _storage_slots[selected_storage_index]
			var storage_unit: Variant = storage_slot.get("unit")
			if storage_unit == null:
				return false
			storage_slot["unit"] = target_unit
			target_slot["unit"] = storage_unit
			target_slot["attack_cooldown_remaining"] = 0.0
			selected_storage_index = -1
			selected_board_unit_instance_id = ""
			selected_story_slot_index = story_slot_index
			status_message = "Swapped storage unit with story slot %d." % [story_slot_index + 1]
		"board":
			for occupant: Dictionary in _board_units:
				var board_unit: Dictionary = occupant.get("unit", {})
				if str(board_unit.get("instance_id", "")) != selected_board_unit_instance_id:
					continue
				occupant["unit"] = target_unit
				target_slot["unit"] = board_unit
				target_slot["attack_cooldown_remaining"] = 0.0
				selected_storage_index = -1
				selected_board_unit_instance_id = ""
				selected_story_slot_index = story_slot_index
				status_message = "Swapped board unit with story slot %d." % [story_slot_index + 1]
				board_changed.emit()
				storage_changed.emit()
				selection_changed.emit()
				round_state_changed.emit()
				_log_debug("unit_swapped", {
					"source": "board",
					"story_slot_index": story_slot_index,
				})
				return true
			return false
		"story":
			if selected_story_slot_index < 0 or selected_story_slot_index >= _story_slots.size():
				return false
			var selected_slot: Dictionary = _story_slots[selected_story_slot_index]
			var selected_unit: Variant = selected_slot.get("unit")
			if selected_unit == null:
				return false
			selected_slot["unit"] = target_unit
			target_slot["unit"] = selected_unit
			selected_slot["attack_cooldown_remaining"] = 0.0
			target_slot["attack_cooldown_remaining"] = 0.0
			selected_story_slot_index = story_slot_index
			status_message = "Swapped story units."
		_:
			return false

	storage_changed.emit()
	board_changed.emit()
	selection_changed.emit()
	round_state_changed.emit()
	_log_debug("unit_swapped", {
		"source": selected_source,
		"story_slot_index": story_slot_index,
	})
	return true


func execute_merge(recipe_id: String) -> bool:
	var recipe: Dictionary = _find_recipe_by_id(recipe_id)
	if recipe.is_empty():
		status_message = "Merge recipe not found."
		_log_debug("merge_failed", {
			"recipe_id": recipe_id,
			"reason": status_message,
			"anchor_source": _get_selected_unit_source(),
		})
		round_state_changed.emit()
		return false

	var output_unit_definition: Dictionary = _definitions.get("units_by_id", {}).get(str(recipe.get("output_unit_id", "")), {})
	if output_unit_definition.is_empty():
		status_message = "Merge output unit definition is missing."
		_log_debug("merge_failed", {
			"recipe_id": recipe_id,
			"reason": status_message,
		})
		round_state_changed.emit()
		return false

	var anchor_unit: Dictionary = get_selected_anchor_unit()
	if anchor_unit.is_empty():
		status_message = "Select a merge anchor unit first."
		_log_debug("merge_failed", {
			"recipe_id": recipe_id,
			"reason": status_message,
		})
		round_state_changed.emit()
		return false

	var created_unit: Dictionary = _create_owned_unit(output_unit_definition)
	var merge_result: Dictionary = MergeRuntime.execute_merge_for_anchor(
		recipe,
		_storage_slots,
		_board_units,
		_story_slots,
		created_unit,
		str(anchor_unit.get("instance_id", ""))
	)
	if not bool(merge_result.get("success", false)):
		status_message = str(merge_result.get("reason", "Merge failed."))
		_log_debug("merge_failed", {
			"recipe_id": recipe_id,
			"reason": status_message,
			"anchor_source": _get_selected_unit_source(),
			"anchor_instance_id": str(anchor_unit.get("instance_id", "")),
			"anchor_definition_id": str(anchor_unit.get("definition_id", "")),
		})
		round_state_changed.emit()
		return false

	var anchor_source: String = str(merge_result.get("anchor_source", ""))
	if anchor_source == "storage":
		selected_storage_index = int(merge_result.get("anchor_slot_index", -1))
		selected_board_unit_instance_id = ""
	elif anchor_source == "board":
		selected_storage_index = -1
		selected_board_unit_instance_id = str(created_unit.get("instance_id", ""))
		selected_story_slot_index = -1
	elif anchor_source == "story":
		selected_storage_index = -1
		selected_board_unit_instance_id = ""
		selected_story_slot_index = int(merge_result.get("anchor_story_slot_index", -1))
	else:
		selected_storage_index = -1
		selected_board_unit_instance_id = ""
		selected_story_slot_index = -1

	if not _merged_output_exists(str(created_unit.get("instance_id", ""))):
		var recovery_slot_index: int = _find_first_empty_storage_slot()
		_storage_slots[recovery_slot_index]["unit"] = created_unit
		selected_storage_index = recovery_slot_index
		selected_board_unit_instance_id = ""
		selected_story_slot_index = -1
		_log_debug("merge_recovered", {
			"recipe_id": recipe_id,
			"output_instance_id": str(created_unit.get("instance_id", "")),
			"output_definition_id": str(created_unit.get("definition_id", "")),
			"recovery_storage_slot_index": recovery_slot_index,
		})

	_recalculate_storage_count()
	recent_draw_units.clear()
	status_message = "Merged into %s." % str(created_unit.get("display_name", "Unit"))
	_log_debug("merge_succeeded", {
		"recipe_id": recipe_id,
		"anchor_source": anchor_source,
		"anchor_instance_id": str(anchor_unit.get("instance_id", "")),
		"anchor_definition_id": str(anchor_unit.get("definition_id", "")),
		"output_instance_id": str(created_unit.get("instance_id", "")),
		"output_definition_id": str(created_unit.get("definition_id", "")),
		"output_display_name": str(created_unit.get("display_name", "Unit")),
		"output_location": _describe_unit_location(str(created_unit.get("instance_id", ""))),
	})

	storage_changed.emit()
	board_changed.emit()
	selection_changed.emit()
	round_state_changed.emit()
	return true


func swap_selected_board_unit_with(target_instance_id: String) -> bool:
	if selected_board_unit_instance_id.is_empty() or selected_board_unit_instance_id == target_instance_id:
		select_board_unit(target_instance_id)
		return false

	var selected_index: int = -1
	var target_index: int = -1
	for index in range(_board_units.size()):
		var occupant: Dictionary = _board_units[index]
		var unit: Dictionary = occupant.get("unit", {})
		var instance_id: String = str(unit.get("instance_id", ""))
		if instance_id == selected_board_unit_instance_id:
			selected_index = index
		elif instance_id == target_instance_id:
			target_index = index

	if selected_index < 0 or target_index < 0:
		select_board_unit(target_instance_id)
		return false

	var selected_position: Vector2i = _board_units[selected_index].get("position", Vector2i.ZERO)
	var target_position: Vector2i = _board_units[target_index].get("position", Vector2i.ZERO)
	_board_units[selected_index]["position"] = target_position
	_board_units[target_index]["position"] = selected_position
	selected_board_unit_instance_id = target_instance_id
	status_message = "Swapped board unit positions."
	_log_debug("board_swap", {
		"selected_instance_id": str(_board_units[target_index].get("unit", {}).get("instance_id", "")),
		"target_instance_id": str(_board_units[selected_index].get("unit", {}).get("instance_id", "")),
		"selected_new_position": _vector_to_array(target_position),
		"target_new_position": _vector_to_array(selected_position),
	})
	board_changed.emit()
	selection_changed.emit()
	round_state_changed.emit()
	return true


func restart_run() -> void:
	difficulty_selected = false
	_reset_runtime()


func select_difficulty(next_difficulty_id: String) -> void:
	var difficulty: Dictionary = _definitions.get("difficulties_by_id", {}).get(next_difficulty_id, {})
	if difficulty.is_empty():
		status_message = "Selected difficulty was not found."
		round_state_changed.emit()
		return

	difficulty_id = next_difficulty_id
	difficulty_selected = true
	_reset_runtime()
	status_message = "%s selected. Prepare your board." % str(difficulty.get("display_name", next_difficulty_id))
	round_state_changed.emit()


func place_selected_unit(row: int, col: int) -> bool:
	var selected_source: String = _get_selected_unit_source()
	if selected_source.is_empty():
		selected_board_unit_instance_id = ""
		selection_changed.emit()
		status_message = "Select a unit before placing."
		_log_debug("action_failed", {
			"action": "place_unit",
			"reason": status_message,
			"target_position": [row, col],
		})
		round_state_changed.emit()
		return false

	if row < 0 or row >= board_rows or col < 0 or col >= board_cols:
		selected_board_unit_instance_id = ""
		selection_changed.emit()
		status_message = "That tile is outside the board."
		_log_debug("action_failed", {
			"action": "place_unit",
			"reason": status_message,
			"target_position": [row, col],
		})
		round_state_changed.emit()
		return false

	var position: Vector2i = Vector2i(row, col)
	if path_tiles.has(position):
		selected_board_unit_instance_id = ""
		selection_changed.emit()
		status_message = "Units cannot be placed on the enemy lane."
		_log_debug("action_failed", {
			"action": "place_unit",
			"reason": status_message,
			"target_position": [row, col],
		})
		round_state_changed.emit()
		return false

	if _get_board_unit_at(position) != null:
		selected_board_unit_instance_id = ""
		selection_changed.emit()
		status_message = "That tile is already occupied."
		_log_debug("action_failed", {
			"action": "place_unit",
			"reason": status_message,
			"target_position": [row, col],
		})
		round_state_changed.emit()
		return false

	var consumed: Dictionary = _take_selected_unit()
	if consumed.is_empty():
		status_message = "The selected unit is no longer available."
		_log_debug("action_failed", {
			"action": "place_unit",
			"reason": status_message,
			"target_position": [row, col],
		})
		selection_changed.emit()
		round_state_changed.emit()
		return false

	var unit: Dictionary = consumed.get("unit", {})
	var board_attack_cooldown: float = float(consumed.get("attack_cooldown_remaining", 0.0))
	_board_units.append({
		"unit": unit,
		"position": position,
		"attack_cooldown_remaining": board_attack_cooldown,
	})
	selected_storage_index = -1
	selected_board_unit_instance_id = ""
	selected_story_slot_index = -1
	_recalculate_storage_count()
	status_message = "Placed %s at [%d, %d]." % [str(unit.get("display_name", "Unit")), row, col]
	_log_debug("unit_moved", {
		"from": selected_source,
		"to": "board",
		"instance_id": str(unit.get("instance_id", "")),
		"definition_id": str(unit.get("definition_id", "")),
		"display_name": str(unit.get("display_name", "Unit")),
		"board_position": [row, col],
	})

	storage_changed.emit()
	board_changed.emit()
	selection_changed.emit()
	round_state_changed.emit()
	return true


func start_round() -> bool:
	return _start_next_round()


func process_round(delta: float) -> bool:
	if not difficulty_selected or game_over:
		return false

	var changed: bool = false
	round_elapsed_seconds += delta
	_step_story_lane(delta)
	_decay_mission_boss_cooldowns(delta)
	seconds_until_next_round -= delta
	while seconds_until_next_round <= 0.0:
		if _start_next_round():
			changed = true
		seconds_until_next_round += ROUND_INTERVAL_SECONDS

	var total_pending_events: int = 0
	for index in range(_active_round_spawners.size() - 1, -1, -1):
		var spawner: Dictionary = _active_round_spawners[index]
		spawner["elapsed_seconds"] = float(spawner.get("elapsed_seconds", 0.0)) + delta
		var spawner_events: Array[Dictionary] = spawner.get("events", [])
		var spawned_enemies: Array[Dictionary] = RoundRuntime.spawn_due_enemies(
			float(spawner.get("elapsed_seconds", 0.0)),
			spawner_events,
			_definitions.get("enemies_by_id", {}),
			_definitions.get("bosses_by_id", {}),
			_get_current_difficulty()
		)
		if not spawned_enemies.is_empty():
			_active_enemies.append_array(spawned_enemies)
			changed = true

		total_pending_events += spawner_events.size()
		if spawner_events.is_empty():
			_active_round_spawners.remove_at(index)

	pending_spawn_count = total_pending_events
	_refresh_round_active_state()

	var leaked_this_tick: int = RoundRuntime.advance_enemies(_active_enemies, delta, path_tiles.size())
	_decay_enemy_visual_timers(delta)
	if leaked_this_tick > 0:
		leaked_enemy_count += leaked_this_tick
		changed = true

	if _is_game_over_from_active_enemy_count():
		round_active = false
		game_over = true
		game_over_reason = "Enemy buildup limit reached"
		_spawn_schedule.clear()
		_active_round_spawners.clear()
		pending_spawn_count = 0
		status_message = "Game over. Enemy count reached %d / %d. Press Restart Run." % [_active_enemies.size(), get_current_active_enemy_limit()]
		enemies_changed.emit()
		round_state_changed.emit()
		return true

	if not _board_units.is_empty() and not _active_enemies.is_empty():
		var defeated_enemy_lookup: Dictionary = {}
		for enemy_snapshot: Dictionary in _active_enemies:
			defeated_enemy_lookup[str(enemy_snapshot.get("instance_id", ""))] = enemy_snapshot.duplicate(true)

		var combat_result: Dictionary = CombatRuntime.step_combat(_board_units, _active_enemies, path_tiles, delta)
		var attacks: Array[Dictionary] = combat_result.get("attacks", [])
		var defeated_ids: Array[String] = combat_result.get("defeated_enemy_ids", [])
		var gold_earned: int = int(combat_result.get("gold_earned", 0))

		if not attacks.is_empty():
			total_attack_count_this_round += attacks.size()
			changed = true

		if not defeated_ids.is_empty():
			defeated_enemy_count_this_round += defeated_ids.size()
			for defeated_id: String in defeated_ids:
				var defeated_enemy: Dictionary = defeated_enemy_lookup.get(defeated_id, {})
				if bool(defeated_enemy.get("is_mission_boss", false)):
					_handle_mission_boss_clear(str(defeated_enemy.get("mission_id", "")))
				elif bool(defeated_enemy.get("is_boss", false)):
					_handle_round_boss_clear(str(defeated_enemy.get("definition_id", "")))
			changed = true

		if gold_earned > 0:
			round_gold_earned += gold_earned
			current_gold += gold_earned
			changed = true

	_sync_current_mission_boss()
	_refresh_round_active_state()

	if changed:
		_update_round_status()

	if changed:
		enemies_changed.emit()
		round_state_changed.emit()

	return changed


func _reset_runtime() -> void:
	var board: Dictionary = _definitions.get("board", {})
	var storage: Dictionary = board.get("storage", {})

	board_rows = int(board.get("rows", BOARD_ROWS))
	board_cols = int(board.get("cols", BOARD_COLS))
	path_tiles = _definitions.get("path_tiles", [])
	storage_capacity = int(storage.get("base_slots", STORAGE_CAPACITY))
	current_round = 0
	leaked_enemy_count = 0
	current_gold = 0
	selected_storage_index = -1
	selected_board_unit_instance_id = ""
	selected_story_slot_index = -1
	round_active = false
	round_elapsed_seconds = 0.0
	pending_spawn_count = 0
	next_round_number = 1
	seconds_until_next_round = INITIAL_ROUND_DELAY_SECONDS
	defeated_enemy_count_this_round = 0
	total_attack_count_this_round = 0
	round_gold_earned = 0
	recent_draw_units.clear()
	status_message = "Select a difficulty to begin." if not difficulty_selected else "Select a storage unit, then click a board tile."
	last_error = ""
	game_over = false
	game_over_reason = ""
	story_boss_stage = 1
	story_boss_completed = false
	story_boss_current_hp = int(_definitions.get("story_boss_stages_by_stage", {}).get(1, {}).get("max_hp", 1))
	current_mission_boss = {}
	_board_units.clear()
	_story_slots.clear()
	_active_enemies.clear()
	_spawn_schedule.clear()
	_active_round_spawners.clear()
	_mission_boss_states.clear()
	_storage_slots.clear()

	for slot_index in range(storage_capacity):
		_storage_slots.append({
			"index": slot_index,
			"unit": null,
		})

	for story_slot_index in range(STORY_SLOT_COUNT):
		_story_slots.append({
			"index": story_slot_index,
			"unit": null,
			"attack_cooldown_remaining": 0.0,
		})

	for mission_definition: Dictionary in _definitions.get("mission_bosses", []):
		_mission_boss_states.append({
			"id": str(mission_definition.get("id", "")),
			"unlock_round": int(mission_definition.get("unlock_round", 0)),
			"unlocked": false,
			"cooldown_remaining": 0.0,
			"first_clear_done": false,
		})

	_unit_instance_counter = 0
	_draw_common_units(_get_base_common_draws_per_round())

	_recalculate_storage_count()
	storage_changed.emit()
	board_changed.emit()
	enemies_changed.emit()
	selection_changed.emit()
	round_state_changed.emit()


func _finish_round() -> void:
	round_active = false
	current_round += 1
	var drawn_count: int = _draw_common_units(_get_base_common_draws_per_round())
	pending_spawn_count = 0
	status_message = "Round cleared. Defeated %d enemies and earned %d gold. Drew %d common units for round %d." % [
		defeated_enemy_count_this_round,
		round_gold_earned,
		drawn_count,
		current_round,
	]
	storage_changed.emit()


func _draw_common_units(count: int) -> int:
	recent_draw_units.clear()
	return _draw_units_by_rarity("common", count, true)


func _draw_specific_unit(unit_definition_id: String, clear_recent: bool) -> bool:
	var unit_definition: Dictionary = _definitions.get("units_by_id", {}).get(unit_definition_id, {})
	if unit_definition.is_empty():
		if clear_recent:
			recent_draw_units.clear()
		return false

	if clear_recent:
		recent_draw_units.clear()

	var empty_slot: int = _find_first_empty_storage_slot()
	if empty_slot < 0:
		return false

	var created_unit: Dictionary = _create_owned_unit(unit_definition)
	_storage_slots[empty_slot]["unit"] = created_unit
	recent_draw_units.append(created_unit)
	_recalculate_storage_count()
	return true


func _get_forge_upgrade_label(upgrade_id: String) -> String:
	for definition: Dictionary in FORGE_UPGRADE_DEFINITIONS:
		if str(definition.get("id", "")) == upgrade_id:
			return str(definition.get("label", upgrade_id))
	return upgrade_id


func _find_first_empty_storage_slot() -> int:
	for index in range(_storage_slots.size()):
		if _storage_slots[index].get("unit") == null:
			return index

	var new_index: int = _storage_slots.size()
	_storage_slots.append({
		"index": new_index,
		"unit": null,
	})
	storage_capacity = _storage_slots.size()
	return new_index


func _create_owned_unit(unit_definition: Dictionary) -> Dictionary:
	_unit_instance_counter += 1
	return {
		"instance_id": "unit_%03d" % _unit_instance_counter,
		"definition_id": str(unit_definition.get("id", "")),
		"display_name": str(unit_definition.get("display_name", "")),
		"rarity": str(unit_definition.get("rarity", "")),
		"definition": unit_definition,
	}


func _get_current_difficulty() -> Dictionary:
	return _definitions.get("difficulties_by_id", {}).get(difficulty_id, {})


func _get_board_unit_at(position: Vector2i):
	for occupant in _board_units:
		if occupant.get("position") == position:
			return occupant
	return null


func _update_round_status() -> void:
	var next_text := " | next %ds" % int(ceil(seconds_until_next_round))
	status_message = "Round %d: %d active | %d queued | %d defeated | %d gold%s" % [
		current_round,
		_active_enemies.size(),
		pending_spawn_count,
		defeated_enemy_count_this_round,
		round_gold_earned,
		next_text,
	]

func _is_game_over_from_active_enemy_count() -> bool:
	return _active_enemies.size() >= get_current_active_enemy_limit()


func _recalculate_storage_count() -> void:
	var count: int = 0
	for slot in _storage_slots:
		if slot.get("unit") != null:
			count += 1
	storage_count = count


func _get_selected_unit_source() -> String:
	if selected_storage_index >= 0 and selected_storage_index < _storage_slots.size():
		if _storage_slots[selected_storage_index].get("unit") != null:
			return "storage"

	if not selected_board_unit_instance_id.is_empty():
		for occupant: Dictionary in _board_units:
			var unit: Dictionary = occupant.get("unit", {})
			if str(unit.get("instance_id", "")) == selected_board_unit_instance_id:
				return "board"

	if selected_story_slot_index >= 0 and selected_story_slot_index < _story_slots.size():
		if _story_slots[selected_story_slot_index].get("unit") != null:
			return "story"

	return ""


func _take_selected_unit() -> Dictionary:
	var source: String = _get_selected_unit_source()
	match source:
		"storage":
			var storage_slot: Dictionary = _storage_slots[selected_storage_index]
			var storage_unit: Variant = storage_slot.get("unit")
			if storage_unit == null:
				return {}
			storage_slot["unit"] = null
			selected_storage_index = -1
			selected_board_unit_instance_id = ""
			selected_story_slot_index = -1
			return {
				"source": "storage",
				"unit": storage_unit,
				"attack_cooldown_remaining": 0.0,
			}
		"board":
			for occupant_index in range(_board_units.size()):
				var occupant: Dictionary = _board_units[occupant_index]
				var board_unit: Dictionary = occupant.get("unit", {})
				if str(board_unit.get("instance_id", "")) != selected_board_unit_instance_id:
					continue
				_board_units.remove_at(occupant_index)
				selected_storage_index = -1
				selected_board_unit_instance_id = ""
				selected_story_slot_index = -1
				return {
					"source": "board",
					"unit": board_unit,
					"attack_cooldown_remaining": float(occupant.get("attack_cooldown_remaining", 0.0)),
				}
		"story":
			var story_slot: Dictionary = _story_slots[selected_story_slot_index]
			var story_unit: Variant = story_slot.get("unit")
			if story_unit == null:
				return {}
			story_slot["unit"] = null
			story_slot["attack_cooldown_remaining"] = 0.0
			selected_storage_index = -1
			selected_board_unit_instance_id = ""
			selected_story_slot_index = -1
			return {
				"source": "story",
				"unit": story_unit,
				"attack_cooldown_remaining": 0.0,
			}

	return {}


func _refresh_round_active_state() -> void:
	round_active = not _active_round_spawners.is_empty() or not _active_enemies.is_empty()


func _sync_current_mission_boss() -> void:
	if current_mission_boss.is_empty():
		return

	var target_instance_id: String = str(current_mission_boss.get("instance_id", ""))
	for enemy: Dictionary in _active_enemies:
		if str(enemy.get("instance_id", "")) == target_instance_id:
			current_mission_boss = {
				"id": str(enemy.get("mission_id", current_mission_boss.get("id", ""))),
				"display_name": str(current_mission_boss.get("display_name", enemy.get("display_name", "Mission Boss"))),
				"boss_definition_id": str(current_mission_boss.get("boss_definition_id", enemy.get("definition_id", ""))),
				"instance_id": target_instance_id,
				"current_hp": int(enemy.get("current_hp", 0)),
				"max_hp": int(enemy.get("max_hp", 1)),
				"armor": float(enemy.get("armor", 0.0)),
				"magic_resist": float(enemy.get("magic_resist", 0.0)),
			}
			return


func _merged_output_exists(instance_id: String) -> bool:
	if instance_id.is_empty():
		return false

	for slot: Dictionary in _storage_slots:
		var storage_unit: Variant = slot.get("unit")
		if storage_unit != null and str(storage_unit.get("instance_id", "")) == instance_id:
			return true

	for occupant: Dictionary in _board_units:
		var board_unit: Dictionary = occupant.get("unit", {})
		if str(board_unit.get("instance_id", "")) == instance_id:
			return true

	for story_slot: Dictionary in _story_slots:
		var story_unit: Variant = story_slot.get("unit")
		if story_unit != null and str(story_unit.get("instance_id", "")) == instance_id:
			return true

	return false


func _describe_unit_location(instance_id: String) -> Dictionary:
	if instance_id.is_empty():
		return {}

	for index in range(_storage_slots.size()):
		var storage_unit: Variant = _storage_slots[index].get("unit")
		if storage_unit != null and str(storage_unit.get("instance_id", "")) == instance_id:
			return {
				"source": "storage",
				"slot_index": index,
			}

	for occupant: Dictionary in _board_units:
		var board_unit: Dictionary = occupant.get("unit", {})
		if str(board_unit.get("instance_id", "")) == instance_id:
			return {
				"source": "board",
				"position": _vector_to_array(occupant.get("position", Vector2i.ZERO)),
			}

	for index in range(_story_slots.size()):
		var story_unit: Variant = _story_slots[index].get("unit")
		if story_unit != null and str(story_unit.get("instance_id", "")) == instance_id:
			return {
				"source": "story",
				"slot_index": index,
			}

	for enemy: Dictionary in _active_enemies:
		if str(enemy.get("instance_id", "")) == instance_id:
			return {
				"source": "enemy_lane",
				"path_index": int(enemy.get("path_index", 0)),
			}

	return {}


func _vector_to_array(value: Variant) -> Array[int]:
	var position: Vector2i = value if value is Vector2i else Vector2i.ZERO
	return [position.x, position.y]


func _log_debug(category: String, data: Dictionary = {}) -> void:
	DebugLogger.write_event(category, data)

func _find_recipe_by_id(recipe_id: String) -> Dictionary:
	for recipe: Dictionary in _definitions.get("recipes", []):
		if str(recipe.get("id", "")) == recipe_id:
			return recipe
	return {}


func _get_base_common_draws_per_round() -> int:
	var reward_rules: Dictionary = _definitions.get("round_draw_rules", {})
	return max(0, int(reward_rules.get("base_common_draws_per_round", 2)))


func _decay_enemy_visual_timers(delta: float) -> void:
	for enemy: Dictionary in _active_enemies:
		var next_flash: float = max(0.0, float(enemy.get("hit_flash_remaining", 0.0)) - delta)
		enemy["hit_flash_remaining"] = next_flash


func _start_next_round() -> bool:
	if game_over or not difficulty_selected:
		return false

	if next_round_number > 60:
		status_message = "Round 60 cleared. Survival target complete."
		round_state_changed.emit()
		return false

	var wave: Dictionary = _get_wave_for_round(next_round_number)
	if wave.is_empty():
		status_message = "No more wave data after round %d." % current_round
		round_state_changed.emit()
		return false

	var round_to_start: int = next_round_number
	var difficulty: Dictionary = _get_current_difficulty()
	var boss_id_value: Variant = wave.get("boss_id", null)
	var boss_id_text: String = "" if boss_id_value == null else str(boss_id_value)
	var schedule_events: Array[Dictionary] = RoundRuntime.create_spawn_schedule(round_to_start, wave, difficulty)

	_active_round_spawners.append({
		"round": round_to_start,
		"elapsed_seconds": 0.0,
		"events": schedule_events,
	})
	current_round = round_to_start
	next_round_number += 1
	round_active = true
	pending_spawn_count += schedule_events.size()
	defeated_enemy_count_this_round = 0
	total_attack_count_this_round = 0
	round_gold_earned = 0
	var drawn_count: int = _draw_common_units(_get_base_common_draws_per_round())
	status_message = "Boss round %d started. Drew %d units." % [round_to_start, drawn_count] if not boss_id_text.is_empty() else "Round %d started. Drew %d units." % [round_to_start, drawn_count]
	storage_changed.emit()
	return true


func _get_wave_for_round(round_number: int) -> Dictionary:
	var existing_wave: Dictionary = _definitions.get("waves_by_round", {}).get(round_number, {})
	if not existing_wave.is_empty():
		return existing_wave

	var runner_count: int = 16 + (round_number - 20) * 2
	var brute_count: int = 10 + int((round_number - 20) / 2)
	var mystic_count: int = 10 + int((round_number - 20) / 2)
	var wave := {
		"round": round_number,
		"entries": [
			{ "enemy_id": "enemy_runner", "count": runner_count, "spawn_interval": max(0.22, 0.35 - float(round_number - 20) * 0.003) },
			{ "enemy_id": "enemy_brute", "count": brute_count, "spawn_interval": max(0.5, 0.75 - float(round_number - 20) * 0.004) },
			{ "enemy_id": "enemy_mystic", "count": mystic_count, "spawn_interval": max(0.44, 0.68 - float(round_number - 20) * 0.003) }
		],
		"boss_id": _boss_id_for_round(round_number)
	}
	return wave


func _boss_id_for_round(round_number: int):
	match round_number:
		10:
			return "boss_guardian_round_10"
		20:
			return "boss_emperor_round_20"
		30:
			return "boss_tempest_round_30"
		40:
			return "boss_abyss_round_40"
		50:
			return "boss_eclipse_round_50"
		_:
			return null


func _step_story_lane(delta: float) -> void:
	if story_boss_completed:
		return

	for slot: Dictionary in _story_slots:
		var unit: Variant = slot.get("unit")
		if unit == null:
			continue

		var cooldown: float = max(0.0, float(slot.get("attack_cooldown_remaining", 0.0)) - delta)
		slot["attack_cooldown_remaining"] = cooldown
		if cooldown > 0.0:
			continue

		var target: Dictionary = get_story_boss_state()
		if target.is_empty() or bool(target.get("completed", false)):
			continue

		var unit_definition: Dictionary = unit.get("definition", {})
		var attack_profile: Dictionary = unit_definition.get("attack", {})
		var offense: Dictionary = _resolve_unit_offense(unit_definition)
		var raw_damage: float = 0.0
		if str(attack_profile.get("damage_type", "physical")) == "physical":
			raw_damage = float(offense.get("physical_damage", 0.0)) - float(target.get("armor", 0.0))
		else:
			raw_damage = float(offense.get("magic_damage", 0.0)) * (1.0 - float(target.get("magic_resist", 0.0)))

		var applied_damage: int = maxi(1, int(round(raw_damage)))
		slot["attack_cooldown_remaining"] = 1.0 / max(0.001, float(offense.get("attack_speed", 1.0)))

		story_boss_current_hp = maxi(0, story_boss_current_hp - applied_damage)
		if story_boss_current_hp <= 0:
			_handle_story_boss_clear()


func _resolve_unit_offense(unit_definition: Dictionary) -> Dictionary:
	var snapshot: Dictionary = get_unit_combat_snapshot(unit_definition)
	var damage_type: String = str(snapshot.get("damage_type", "physical"))
	var damage_value: float = float(snapshot.get("damage", 0.0))
	return {
		"physical_damage": damage_value if damage_type == "physical" else 0.0,
		"magic_damage": damage_value if damage_type == "magic" else 0.0,
		"attack_speed": float(snapshot.get("attack_speed", 1.0)),
	}


func _handle_story_boss_clear() -> void:
	var stage_definition: Dictionary = _definitions.get("story_boss_stages_by_stage", {}).get(story_boss_stage, {})
	_grant_reward_package(stage_definition.get("reward", {}))
	if story_boss_stage >= 15:
		story_boss_completed = true
		status_message = "Story boss fully conquered."
		return

	story_boss_stage += 1
	story_boss_current_hp = int(_definitions.get("story_boss_stages_by_stage", {}).get(story_boss_stage, {}).get("max_hp", 1))
	status_message = "Story boss stage %d cleared. Stage %d unlocked." % [story_boss_stage - 1, story_boss_stage]


func _handle_round_boss_clear(boss_definition_id: String) -> void:
	var boss_definition: Dictionary = _definitions.get("bosses_by_id", {}).get(boss_definition_id, {})
	if boss_definition.is_empty():
		return

	round_gold_earned += int(boss_definition.get("reward", {}).get("gold", 0))
	_grant_reward_package(boss_definition.get("reward", {}))
	var spawn_round: int = int(boss_definition.get("spawn_round", 0))
	for mission_state: Dictionary in _mission_boss_states:
		if int(mission_state.get("unlock_round", 0)) == spawn_round:
			mission_state["unlocked"] = true
	status_message = "%s defeated. Mission unlocks updated." % str(boss_definition.get("display_name", "Boss"))


func _handle_mission_boss_clear(mission_id: String = "") -> void:
	if mission_id.is_empty():
		mission_id = str(current_mission_boss.get("id", ""))
	for mission_state: Dictionary in _mission_boss_states:
		if str(mission_state.get("id", "")) != mission_id:
			continue

		var mission_definition: Dictionary = _definitions.get("mission_bosses_by_id", {}).get(mission_id, {})
		var reward_key := "repeat_clear_reward" if bool(mission_state.get("first_clear_done", false)) else "first_clear_reward"
		_grant_reward_package(mission_definition.get(reward_key, {}))
		mission_state["first_clear_done"] = true
		mission_state["cooldown_remaining"] = float(mission_definition.get("cooldown_seconds", 300.0))
		status_message = "%s cleared." % str(mission_definition.get("display_name", "Mission Boss"))
		break

	current_mission_boss = {}


func _grant_reward_package(reward: Dictionary) -> void:
	current_gold += int(reward.get("gold", 0))
	var common_draws: int = int(reward.get("bonus_common_draws", 0))
	var rare_draws: int = int(reward.get("bonus_rare_draws", 0))
	var unique_draws: int = int(reward.get("bonus_unique_draws", 0))
	var legendary_draws: int = int(reward.get("bonus_legendary_draws", 0))
	if common_draws > 0:
		_draw_units_by_rarity("common", common_draws, false)
	if rare_draws > 0:
		_draw_units_by_rarity("rare", rare_draws, false)
	if unique_draws > 0:
		_draw_units_by_rarity("unique", unique_draws, false)
	if legendary_draws > 0:
		_draw_units_by_rarity("legendary", legendary_draws, false)

	_recalculate_storage_count()
	storage_changed.emit()


func _draw_units_by_rarity(rarity: String, count: int, clear_recent: bool) -> int:
	var rarity_ids: Array = _definitions.get("unit_ids_by_rarity", {}).get(rarity, [])
	if rarity_ids.is_empty():
		if clear_recent:
			recent_draw_units.clear()
		return 0

	if clear_recent:
		recent_draw_units.clear()

	var drawn: int = 0
	for _draw_index in range(count):
		var empty_slot: int = _find_first_empty_storage_slot()
		if empty_slot < 0:
			status_message = "Storage is full."
			break

		var random_index: int = _rng.randi_range(0, rarity_ids.size() - 1)
		var unit_definition_id: String = str(rarity_ids[random_index])
		var unit_definition: Dictionary = _definitions.get("units_by_id", {}).get(unit_definition_id, {})
		if unit_definition.is_empty():
			continue

		var created_unit: Dictionary = _create_owned_unit(unit_definition)
		_storage_slots[empty_slot]["unit"] = created_unit
		recent_draw_units.append(created_unit)
		drawn += 1

	_recalculate_storage_count()
	return drawn


func _decay_mission_boss_cooldowns(delta: float) -> void:
	for mission_state: Dictionary in _mission_boss_states:
		mission_state["cooldown_remaining"] = max(0.0, float(mission_state.get("cooldown_remaining", 0.0)) - delta)
