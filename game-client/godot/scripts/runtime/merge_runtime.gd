extends RefCounted

class_name MergeRuntime


static func get_recipe_options_for_anchor(
	recipes: Array,
	storage_slots: Array[Dictionary],
	board_units: Array[Dictionary],
	story_slots: Array[Dictionary],
	anchor_definition_id: String
) -> Array[Dictionary]:
	var inventory_counts: Dictionary = _count_owned_units(storage_slots, board_units, story_slots)
	var recipe_options: Array[Dictionary] = []

	for recipe: Dictionary in recipes:
		if not _recipe_includes_anchor(recipe, anchor_definition_id):
			continue

		var option: Dictionary = recipe.duplicate(true)
		option["can_craft"] = _can_craft_recipe(recipe, inventory_counts)
		recipe_options.append(option)

	return recipe_options


static func execute_merge_for_anchor(
	recipe: Dictionary,
	storage_slots: Array[Dictionary],
	board_units: Array[Dictionary],
	story_slots: Array[Dictionary],
	output_unit: Dictionary,
	anchor_instance_id: String
) -> Dictionary:
	var anchor_consumed: Dictionary = _consume_anchor_instance(storage_slots, board_units, story_slots, anchor_instance_id)
	if anchor_consumed.is_empty():
		return {
			"success": false,
			"reason": "Anchor unit could not be found.",
		}

	var consumed_units: Array[Dictionary] = [anchor_consumed]
	var anchor_unit: Dictionary = anchor_consumed.get("unit", {})
	var anchor_definition_id: String = str(anchor_unit.get("definition_id", ""))

	for input: Dictionary in recipe.get("inputs", []):
		var definition_id: String = str(input.get("unit_id", ""))
		var required_count: int = int(input.get("count", 0))
		if definition_id == anchor_definition_id:
			required_count -= 1

		for _consume_index in range(required_count):
			var consumed: Dictionary = _consume_unit_instance(storage_slots, board_units, story_slots, definition_id)
			if consumed.is_empty():
				_rollback_consumed_units(storage_slots, board_units, story_slots, consumed_units)
				return {
					"success": false,
					"reason": "Required merge materials are missing.",
				}
			consumed_units.append(consumed)

	if not _place_output_at_anchor(storage_slots, board_units, story_slots, anchor_consumed, output_unit):
		_rollback_consumed_units(storage_slots, board_units, story_slots, consumed_units)
		return {
			"success": false,
			"reason": "Could not place merged unit at the anchor location.",
		}

	return {
		"success": true,
		"anchor_source": str(anchor_consumed.get("source", "")),
		"anchor_slot_index": int(anchor_consumed.get("slot_index", -1)),
		"anchor_position": anchor_consumed.get("position", Vector2i.ZERO),
		"anchor_story_slot_index": int(anchor_consumed.get("story_slot_index", -1)),
	}


static func _count_owned_units(storage_slots: Array[Dictionary], board_units: Array[Dictionary], story_slots: Array[Dictionary]) -> Dictionary:
	var counts: Dictionary = {}

	for slot: Dictionary in storage_slots:
		var unit: Variant = slot.get("unit")
		if unit == null:
			continue

		var definition_id: String = str(unit.get("definition_id", ""))
		counts[definition_id] = int(counts.get(definition_id, 0)) + 1

	for occupant: Dictionary in board_units:
		var unit: Dictionary = occupant.get("unit", {})
		var definition_id: String = str(unit.get("definition_id", ""))
		counts[definition_id] = int(counts.get(definition_id, 0)) + 1

	for story_slot: Dictionary in story_slots:
		var story_unit: Variant = story_slot.get("unit")
		if story_unit == null:
			continue
		var story_definition_id: String = str(story_unit.get("definition_id", ""))
		counts[story_definition_id] = int(counts.get(story_definition_id, 0)) + 1

	return counts


static func _recipe_includes_anchor(recipe: Dictionary, anchor_definition_id: String) -> bool:
	for input: Dictionary in recipe.get("inputs", []):
		if str(input.get("unit_id", "")) == anchor_definition_id:
			return true
	return false


static func _can_craft_recipe(recipe: Dictionary, inventory_counts: Dictionary) -> bool:
	for input: Dictionary in recipe.get("inputs", []):
		var definition_id: String = str(input.get("unit_id", ""))
		var required_count: int = int(input.get("count", 0))
		if int(inventory_counts.get(definition_id, 0)) < required_count:
			return false
	return true


static func _consume_anchor_instance(storage_slots: Array[Dictionary], board_units: Array[Dictionary], story_slots: Array[Dictionary], anchor_instance_id: String) -> Dictionary:
	for slot_index in range(storage_slots.size()):
		var slot: Dictionary = storage_slots[slot_index]
		var unit: Variant = slot.get("unit")
		if unit != null and str(unit.get("instance_id", "")) == anchor_instance_id:
			slot["unit"] = null
			return {
				"source": "storage",
				"slot_index": slot_index,
				"unit": unit,
			}

	for occupant_index in range(board_units.size()):
		var occupant: Dictionary = board_units[occupant_index]
		var unit: Dictionary = occupant.get("unit", {})
		if str(unit.get("instance_id", "")) == anchor_instance_id:
			board_units.remove_at(occupant_index)
			return {
				"source": "board",
				"occupant_index": occupant_index,
				"position": occupant.get("position", Vector2i.ZERO),
				"occupant": occupant,
				"unit": unit,
			}

	for story_slot_index in range(story_slots.size()):
		var story_slot: Dictionary = story_slots[story_slot_index]
		var story_unit: Variant = story_slot.get("unit")
		if story_unit != null and str(story_unit.get("instance_id", "")) == anchor_instance_id:
			story_slot["unit"] = null
			story_slot["attack_cooldown_remaining"] = 0.0
			return {
				"source": "story",
				"story_slot_index": story_slot_index,
				"unit": story_unit,
			}

	return {}


static func _consume_unit_instance(storage_slots: Array[Dictionary], board_units: Array[Dictionary], story_slots: Array[Dictionary], definition_id: String) -> Dictionary:
	for slot_index in range(storage_slots.size()):
		var slot: Dictionary = storage_slots[slot_index]
		var unit: Variant = slot.get("unit")
		if unit != null and str(unit.get("definition_id", "")) == definition_id:
			slot["unit"] = null
			return {
				"source": "storage",
				"slot_index": slot_index,
				"unit": unit,
			}

	for occupant_index in range(board_units.size()):
		var occupant: Dictionary = board_units[occupant_index]
		var unit: Dictionary = occupant.get("unit", {})
		if str(unit.get("definition_id", "")) == definition_id:
			board_units.remove_at(occupant_index)
			return {
				"source": "board",
				"occupant_index": occupant_index,
				"position": occupant.get("position", Vector2i.ZERO),
				"occupant": occupant,
				"unit": unit,
			}

	for story_slot_index in range(story_slots.size()):
		var story_slot: Dictionary = story_slots[story_slot_index]
		var story_unit: Variant = story_slot.get("unit")
		if story_unit != null and str(story_unit.get("definition_id", "")) == definition_id:
			story_slot["unit"] = null
			story_slot["attack_cooldown_remaining"] = 0.0
			return {
				"source": "story",
				"story_slot_index": story_slot_index,
				"unit": story_unit,
			}

	return {}


static func _place_output_at_anchor(storage_slots: Array[Dictionary], board_units: Array[Dictionary], story_slots: Array[Dictionary], anchor_consumed: Dictionary, output_unit: Dictionary) -> bool:
	var anchor_source: String = str(anchor_consumed.get("source", ""))
	if anchor_source == "storage":
		var slot_index: int = int(anchor_consumed.get("slot_index", -1))
		if slot_index < 0 or slot_index >= storage_slots.size():
			return false
		storage_slots[slot_index]["unit"] = output_unit
		return true

	if anchor_source == "board":
		board_units.insert(int(anchor_consumed.get("occupant_index", board_units.size())), {
			"unit": output_unit,
			"position": anchor_consumed.get("position", Vector2i.ZERO),
			"attack_cooldown_remaining": 0.0,
		})
		return true

	if anchor_source == "story":
		var story_slot_index: int = int(anchor_consumed.get("story_slot_index", -1))
		if story_slot_index < 0 or story_slot_index >= story_slots.size():
			return false
		story_slots[story_slot_index]["unit"] = output_unit
		story_slots[story_slot_index]["attack_cooldown_remaining"] = 0.0
		return true

	return false


static func _rollback_consumed_units(storage_slots: Array[Dictionary], board_units: Array[Dictionary], story_slots: Array[Dictionary], consumed_units: Array[Dictionary]) -> void:
	for index in range(consumed_units.size() - 1, -1, -1):
		var consumed: Dictionary = consumed_units[index]
		var source: String = str(consumed.get("source", ""))
		if source == "storage":
			var slot_index: int = int(consumed.get("slot_index", -1))
			if slot_index >= 0 and slot_index < storage_slots.size():
				storage_slots[slot_index]["unit"] = consumed.get("unit")
		elif source == "board":
			var occupant_index: int = int(consumed.get("occupant_index", board_units.size()))
			board_units.insert(occupant_index, consumed.get("occupant"))
		elif source == "story":
			var story_slot_index: int = int(consumed.get("story_slot_index", -1))
			if story_slot_index >= 0 and story_slot_index < story_slots.size():
				story_slots[story_slot_index]["unit"] = consumed.get("unit")
				story_slots[story_slot_index]["attack_cooldown_remaining"] = 0.0
