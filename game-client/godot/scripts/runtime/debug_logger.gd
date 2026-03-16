extends RefCounted

class_name DebugLogger

const LOG_DIR := "res://debug_logs"
const LOG_FILE := "res://debug_logs/runtime_debug.log"


static func get_log_path() -> String:
	return ProjectSettings.globalize_path(LOG_FILE)


static func write_event(category: String, data: Dictionary = {}) -> void:
	var directory_path: String = ProjectSettings.globalize_path(LOG_DIR)
	DirAccess.make_dir_recursive_absolute(directory_path)

	var log_path: String = get_log_path()
	var file: FileAccess = null
	if FileAccess.file_exists(log_path):
		file = FileAccess.open(log_path, FileAccess.READ_WRITE)
	else:
		file = FileAccess.open(log_path, FileAccess.WRITE)

	if file == null:
		push_warning("Failed to open debug log file: %s" % log_path)
		return

	file.seek_end()
	file.store_line(JSON.stringify({
		"timestamp": Time.get_datetime_string_from_system(true, true),
		"category": category,
		"data": data,
	}))
	file.flush()
