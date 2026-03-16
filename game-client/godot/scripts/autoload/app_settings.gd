extends Node

signal settings_applied
signal language_changed(language_code: String)

const SETTINGS_PATH := "user://settings.cfg"
const DEFAULT_SETTINGS := {
	"display": {
		"resolution": "1600x900",
	},
	"audio": {
		"master_volume": 1.0,
		"master_mute": false,
		"character_volume": 1.0,
		"character_mute": false,
		"music_volume": 1.0,
		"music_mute": false,
		"ambient_volume": 1.0,
		"ambient_mute": false,
	},
	"language": {
		"code": "ko",
	},
	"creator": {},
}
const TRANSLATIONS := {
	"ko": {
		"menu": "메뉴",
		"back": "뒤로가기",
		"settings": "환경설정",
		"quit": "종료",
		"display": "디스플레이",
		"audio": "오디오",
		"language": "언어",
		"creator": "제작자",
		"reset": "초기화",
		"apply": "적용",
		"cancel": "취소",
		"resolution": "해상도",
		"master_volume": "마스터 볼륨",
		"character_volume": "캐릭터 볼륨",
		"music_volume": "음악 볼륨",
		"ambient_volume": "환경음 볼륨",
		"mute": "음소거",
		"english": "English",
		"korean": "한국어",
		"shop": "상점",
		"mission": "미션",
		"codex": "도감",
		"forge": "대장간",
		"all": "모든",
		"common": "일반",
		"rare": "고급",
		"unique": "희귀",
		"legendary": "전설",
		"transcendent": "초월자",
		"immortal": "불멸자",
		"god": "신",
		"liberator": "해방자",
		"stage_control": "스테이지 컨트롤",
		"story_boss": "스토리 보스",
		"storage": "저장고",
		"settings_saved": "설정값 저장",
		"creator_placeholder": "추후 공개 예정",
	},
	"en": {
		"menu": "Menu",
		"back": "Back",
		"settings": "Settings",
		"quit": "Quit",
		"display": "Display",
		"audio": "Audio",
		"language": "Language",
		"creator": "Credits",
		"reset": "Reset",
		"apply": "Apply",
		"cancel": "Cancel",
		"resolution": "Resolution",
		"master_volume": "Master Volume",
		"character_volume": "Character Volume",
		"music_volume": "Music Volume",
		"ambient_volume": "Ambient Volume",
		"mute": "Mute",
		"english": "English",
		"korean": "Korean",
		"shop": "Shop",
		"mission": "Mission",
		"codex": "Codex",
		"forge": "Forge",
		"all": "All",
		"common": "Common",
		"rare": "Rare",
		"unique": "Unique",
		"legendary": "Legendary",
		"transcendent": "Transcendent",
		"immortal": "Immortal",
		"god": "God",
		"liberator": "Liberator",
		"settings_saved": "Settings applied.",
		"creator_placeholder": "Coming later",
	},
}

var _settings: Dictionary = {}


func _ready() -> void:
	_load_settings()
	_apply_runtime_settings()
	language_changed.emit(get_language_code())


func get_settings_copy() -> Dictionary:
	return _settings.duplicate(true)


func get_default_settings_copy() -> Dictionary:
	return DEFAULT_SETTINGS.duplicate(true)


func get_language_code() -> String:
	return str(_settings.get("language", {}).get("code", "ko"))


func translate_key(key: String) -> String:
	var language_code: String = get_language_code()
	var language_table: Dictionary = TRANSLATIONS.get(language_code, TRANSLATIONS.get("en", {}))
	if language_table.has(key):
		return str(language_table.get(key, key))
	var fallback: Dictionary = TRANSLATIONS.get("en", {})
	return str(fallback.get(key, key))


func apply_settings(next_settings: Dictionary) -> void:
	_settings = _merge_settings(get_default_settings_copy(), next_settings)
	_save_settings()
	_apply_runtime_settings()
	settings_applied.emit()
	language_changed.emit(get_language_code())


func reset_category(category: String) -> void:
	var next_settings: Dictionary = get_settings_copy()
	var defaults: Dictionary = get_default_settings_copy()
	next_settings[category] = defaults.get(category, {}).duplicate(true)
	apply_settings(next_settings)


func _load_settings() -> void:
	_settings = get_default_settings_copy()
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	for category: String in DEFAULT_SETTINGS.keys():
		var defaults: Dictionary = DEFAULT_SETTINGS.get(category, {})
		var stored: Dictionary = config.get_value("settings", category, defaults)
		if stored is Dictionary:
			_settings[category] = _merge_settings(defaults, stored)


func _save_settings() -> void:
	var config := ConfigFile.new()
	for category: String in _settings.keys():
		config.set_value("settings", category, _settings.get(category, {}))
	config.save(SETTINGS_PATH)


func _merge_settings(defaults: Dictionary, overrides: Dictionary) -> Dictionary:
	var result: Dictionary = defaults.duplicate(true)
	for key: Variant in overrides.keys():
		var key_text: String = str(key)
		var default_value: Variant = result.get(key_text, null)
		var override_value: Variant = overrides.get(key_text)
		if default_value is Dictionary and override_value is Dictionary:
			result[key_text] = _merge_settings(default_value, override_value)
		else:
			result[key_text] = override_value
	return result


func _apply_runtime_settings() -> void:
	_apply_display_settings()
	_apply_audio_settings()


func _apply_display_settings() -> void:
	var resolution_text: String = str(_settings.get("display", {}).get("resolution", "1600x900"))
	var parts: PackedStringArray = resolution_text.split("x")
	if parts.size() != 2:
		return
	var resolution := Vector2i(int(parts[0]), int(parts[1]))
	DisplayServer.window_set_size(resolution)
	var window := get_window()
	if window != null:
		window.size = resolution
		window.content_scale_size = resolution


func _apply_audio_settings() -> void:
	var audio_settings: Dictionary = _settings.get("audio", {})
	var bus_mapping := {
		"master": "Master",
		"character": "Character",
		"music": "Music",
		"ambient": "Ambient",
	}
	for key_prefix: String in bus_mapping.keys():
		var bus_name: String = str(bus_mapping.get(key_prefix, "Master"))
		var bus_index: int = _ensure_audio_bus(bus_name)
		var volume: float = clamp(float(audio_settings.get("%s_volume" % key_prefix, 1.0)), 0.0, 1.0)
		var mute: bool = bool(audio_settings.get("%s_mute" % key_prefix, false))
		AudioServer.set_bus_mute(bus_index, mute)
		AudioServer.set_bus_volume_db(bus_index, _linear_to_db(volume))


func _ensure_audio_bus(bus_name: String) -> int:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	if bus_index >= 0:
		return bus_index
	AudioServer.add_bus(AudioServer.get_bus_count())
	bus_index = AudioServer.get_bus_count() - 1
	AudioServer.set_bus_name(bus_index, bus_name)
	return bus_index


func _linear_to_db(value: float) -> float:
	if value <= 0.0001:
		return -80.0
	return linear_to_db(value)
