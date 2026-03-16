extends CanvasLayer

const ActorViewFactory = preload("res://scripts/presentation/actor_view_factory.gd")
const STORAGE_GRID_COLUMNS := 4
@onready var _countdown_caption_label: Label = $TopCenterOverlay/OverlayVBox/CountdownCaptionLabel
@onready var _countdown_value_label: Label = $TopCenterOverlay/OverlayVBox/CountdownValueLabel
@onready var _enemy_warning_label: Label = $TopCenterOverlay/OverlayVBox/EnemyWarningLabel
@onready var _boss_warning_label: Label = $TopCenterOverlay/OverlayVBox/BossWarningLabel
@onready var _round_label: Label = $StatusPanel/MarginContainer/VBoxContainer/RoundLabel
@onready var _timer_label: Label = $StatusPanel/MarginContainer/VBoxContainer/TimerLabel
@onready var _leak_label: Label = $StatusPanel/MarginContainer/VBoxContainer/LeakLabel
@onready var _gold_label: Label = $StatusPanel/MarginContainer/VBoxContainer/GoldLabel
@onready var _enemy_label: Label = $StatusPanel/MarginContainer/VBoxContainer/EnemyLabel
@onready var _combat_label: Label = $StatusPanel/MarginContainer/VBoxContainer/CombatLabel
@onready var _status_label: Label = $StatusPanel/MarginContainer/VBoxContainer/StatusLabel
@onready var _story_stage_label: Label = $StoryPanel/MarginContainer/VBoxContainer/StageLabel
@onready var _story_hp_bar: ProgressBar = $StoryPanel/MarginContainer/VBoxContainer/HpBar
@onready var _story_hp_label: Label = $StoryPanel/MarginContainer/VBoxContainer/HpLabel
@onready var _story_slot_1: Button = $StoryPanel/MarginContainer/VBoxContainer/StorySlots/StorySlot1
@onready var _story_slot_2: Button = $StoryPanel/MarginContainer/VBoxContainer/StorySlots/StorySlot2
@onready var _story_slot_3: Button = $StoryPanel/MarginContainer/VBoxContainer/StorySlots/StorySlot3
@onready var _mission_buttons: VBoxContainer = $MissionPanel/MarginContainer/VBoxContainer/MissionButtons
@onready var _selected_label: Label = $StatusPanel/MarginContainer/VBoxContainer/SelectedLabel
@onready var _storage_label: Label = $StatusPanel/MarginContainer/VBoxContainer/StorageLabel
@onready var _speed_normal_button: Button = $StatusPanel/MarginContainer/VBoxContainer/SpeedButtons/SpeedNormalButton
@onready var _speed_15_button: Button = $StatusPanel/MarginContainer/VBoxContainer/SpeedButtons/Speed15Button
@onready var _speed_20_button: Button = $StatusPanel/MarginContainer/VBoxContainer/SpeedButtons/Speed20Button
@onready var _move_to_storage_button: Button = $StatusPanel/MarginContainer/VBoxContainer/MoveToStorageButton
@onready var _start_round_button: Button = $StatusPanel/MarginContainer/VBoxContainer/StartRoundButton
@onready var _restart_run_button: Button = $StatusPanel/MarginContainer/VBoxContainer/RestartRunButton
@onready var _bottom_shop_button: Button = $MergePanel/MarginContainer/VBoxContainer/BottomTabs/ShopButton
@onready var _bottom_mission_button: Button = $MergePanel/MarginContainer/VBoxContainer/BottomTabs/MissionButton
@onready var _bottom_recipe_button: Button = $MergePanel/MarginContainer/VBoxContainer/BottomTabs/RecipeButton
@onready var _bottom_forge_button: Button = $MergePanel/MarginContainer/VBoxContainer/BottomTabs/ForgeButton
@onready var _unit_info_panel: PanelContainer = $MergePanel/MarginContainer/VBoxContainer/UnitInfoPanel
@onready var _unit_info_name_label: Label = $MergePanel/MarginContainer/VBoxContainer/UnitInfoPanel/MarginContainer/VBoxContainer/UnitNameLabel
@onready var _unit_info_icon: TextureRect = $MergePanel/MarginContainer/VBoxContainer/UnitInfoPanel/MarginContainer/VBoxContainer/ContentRow/IconPanel/UnitIcon
@onready var _unit_info_grade_label: Label = $MergePanel/MarginContainer/VBoxContainer/UnitInfoPanel/MarginContainer/VBoxContainer/ContentRow/StatsGrid/GradeLabel
@onready var _unit_info_strength_label: Label = $MergePanel/MarginContainer/VBoxContainer/UnitInfoPanel/MarginContainer/VBoxContainer/ContentRow/StatsGrid/StrengthLabel
@onready var _unit_info_damage_label: Label = $MergePanel/MarginContainer/VBoxContainer/UnitInfoPanel/MarginContainer/VBoxContainer/ContentRow/StatsGrid/DamageLabel
@onready var _unit_info_agility_label: Label = $MergePanel/MarginContainer/VBoxContainer/UnitInfoPanel/MarginContainer/VBoxContainer/ContentRow/StatsGrid/AgilityLabel
@onready var _unit_info_attack_speed_label: Label = $MergePanel/MarginContainer/VBoxContainer/UnitInfoPanel/MarginContainer/VBoxContainer/ContentRow/StatsGrid/AttackSpeedLabel
@onready var _unit_info_intelligence_label: Label = $MergePanel/MarginContainer/VBoxContainer/UnitInfoPanel/MarginContainer/VBoxContainer/ContentRow/StatsGrid/IntelligenceLabel
@onready var _unit_info_recipe_cards: HFlowContainer = $MergePanel/MarginContainer/VBoxContainer/UnitInfoPanel/MarginContainer/VBoxContainer/ContentRow/RightColumn/RecipeCards
@onready var _unit_info_skill_label: Label = $MergePanel/MarginContainer/VBoxContainer/UnitInfoPanel/MarginContainer/VBoxContainer/ContentRow/RightColumn/SkillPlaceholderLabel
@onready var _unit_recipe_tooltip: PanelContainer = $MergePanel/MarginContainer/VBoxContainer/UnitRecipeTooltip
@onready var _unit_recipe_tooltip_label: Label = $MergePanel/MarginContainer/VBoxContainer/UnitRecipeTooltip/MarginContainer/VBoxContainer/TooltipTextLabel
@onready var _unit_recipe_tooltip_icons: HFlowContainer = $MergePanel/MarginContainer/VBoxContainer/UnitRecipeTooltip/MarginContainer/VBoxContainer/TooltipIcons
@onready var _bottom_title_label: Label = $MergePanel/MarginContainer/VBoxContainer/ContentTitleLabel
@onready var _merge_hint_label: Label = $MergePanel/MarginContainer/VBoxContainer/ContentHintLabel
@onready var _merge_options: VBoxContainer = $MergePanel/MarginContainer/VBoxContainer/MergeOptions
@onready var _shop_content_label: Label = $MergePanel/MarginContainer/VBoxContainer/ShopContentLabel
@onready var _quest_content_label: Label = $MergePanel/MarginContainer/VBoxContainer/QuestContentLabel
@onready var _forge_content_label: Label = $MergePanel/MarginContainer/VBoxContainer/ForgeContentLabel
@onready var _recipe_overlay: Control = $RecipeBrowserOverlay
@onready var _recipe_overlay_dim: ColorRect = $RecipeBrowserOverlay/Dim
@onready var _recipe_overlay_panel: PanelContainer = $RecipeBrowserOverlay/CenterContainer/PanelContainer
@onready var _recipe_overlay_title: Label = $RecipeBrowserOverlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HeaderRow/TitleLabel
@onready var _recipe_overlay_close_button: Button = $RecipeBrowserOverlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HeaderRow/CloseButton
@onready var _recipe_all_button: Button = $RecipeBrowserOverlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/RarityButtons/AllButton
@onready var _recipe_rare_button: Button = $RecipeBrowserOverlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/RarityButtons/RareButton
@onready var _recipe_unique_button: Button = $RecipeBrowserOverlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/RarityButtons/UniqueButton
@onready var _recipe_legendary_button: Button = $RecipeBrowserOverlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/RarityButtons/LegendaryButton
@onready var _recipe_transcendent_button: Button = $RecipeBrowserOverlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/RarityButtons/TranscendentButton
@onready var _recipe_immortal_button: Button = $RecipeBrowserOverlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/RarityButtons/ImmortalButton
@onready var _recipe_god_button: Button = $RecipeBrowserOverlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/RarityButtons/GodButton
@onready var _recipe_liberator_button: Button = $RecipeBrowserOverlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/RarityButtons/LiberatorButton
@onready var _recipe_browser_hint_label: Label = $RecipeBrowserOverlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HintLabel
@onready var _recipe_browser_list: VBoxContainer = $RecipeBrowserOverlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/RecipeScroll/RecipeList
@onready var _sidebar_vbox: VBoxContainer = $Sidebar/MarginContainer/VBoxContainer
@onready var _storage_help_label: Label = $Sidebar/MarginContainer/VBoxContainer/StorageHelpLabel
@onready var _storage_grid: GridContainer = $Sidebar/MarginContainer/VBoxContainer/StorageScroll/StorageGrid
@onready var _difficulty_panel: PanelContainer = $DifficultyPanel
@onready var _easy_button: Button = $DifficultyPanel/MarginContainer/VBoxContainer/DifficultyButtons/EasyButton
@onready var _normal_button: Button = $DifficultyPanel/MarginContainer/VBoxContainer/DifficultyButtons/NormalButton
@onready var _hard_button: Button = $DifficultyPanel/MarginContainer/VBoxContainer/DifficultyButtons/HardButton
@onready var _mission_panel: PanelContainer = $MissionPanel

signal storage_unit_selected(instance_id: String)
signal merge_requested(recipe_id: String)
signal restart_requested
signal difficulty_selected(difficulty_id: String)
signal story_slot_requested(slot_index: int)
signal mission_boss_requested(mission_id: String)
signal start_round_requested
signal move_to_storage_requested
signal speed_requested(multiplier: float)

var current_speed_multiplier: float = 1.0
var _bottom_tab: String = ""
var _recipe_browser_rarity: String = "rare"
var _recipe_browser_filter_output_ids: Array[String] = []
var _shop_overlay: Control
var _shop_overlay_panel: PanelContainer
var _shop_overlay_title: Label
var _shop_random_button: Button
var _shop_random_info_label: Label
var _shop_selected_rarity: String = "common"
var _shop_rarity_buttons: Dictionary = {}
var _shop_unit_grid: GridContainer
var _shop_status_label: Label
var _mission_overlay: Control
var _mission_overlay_panel: PanelContainer
var _mission_overlay_title: Label
var _mission_overlay_hint: Label
var _mission_overlay_buttons: VBoxContainer
var _forge_overlay: Control
var _forge_overlay_panel: PanelContainer
var _forge_overlay_title: Label
var _forge_overlay_list: VBoxContainer
var _forge_overlay_hint: Label
var _unit_recipe_tooltip_formula_flow: HFlowContainer
var _storage_tab_bar: HBoxContainer
var _storage_rarity_filter: String = ""
var _storage_filter_buttons: Dictionary = {}
var _pause_overlay: Control
var _pause_panel: PanelContainer
var _pause_title_label: Label
var _pause_back_button: Button
var _pause_settings_button: Button
var _pause_quit_button: Button
var _settings_overlay: Control
var _settings_panel: PanelContainer
var _settings_title_label: Label
var _settings_tab_container: TabContainer
var _settings_reset_button: Button
var _settings_apply_button: Button
var _settings_cancel_button: Button
var _settings_resolution_option: OptionButton
var _settings_language_option: OptionButton
var _settings_audio_controls: Dictionary = {}
var _settings_pending: Dictionary = {}
var _is_updating_settings_controls: bool = false


func _ready() -> void:
	_start_round_button.pressed.connect(_on_start_round_pressed)
	_move_to_storage_button.pressed.connect(_on_move_to_storage_pressed)
	_restart_run_button.pressed.connect(_on_restart_run_pressed)
	_speed_normal_button.pressed.connect(_on_speed_pressed.bind(1.0))
	_speed_15_button.pressed.connect(_on_speed_pressed.bind(1.5))
	_speed_20_button.pressed.connect(_on_speed_pressed.bind(2.0))
	_bottom_shop_button.pressed.connect(_on_shop_overlay_open_pressed)
	_bottom_mission_button.pressed.connect(_on_mission_overlay_open_pressed)
	_bottom_recipe_button.pressed.connect(_on_recipe_browser_open_pressed)
	_bottom_forge_button.pressed.connect(_on_forge_overlay_open_pressed)
	_recipe_overlay_close_button.pressed.connect(_on_recipe_browser_close_pressed)
	_recipe_overlay.gui_input.connect(_on_recipe_overlay_input)
	_recipe_overlay_dim.gui_input.connect(_on_recipe_overlay_dim_input)
	_recipe_all_button.pressed.connect(_on_recipe_rarity_pressed.bind(""))
	_recipe_rare_button.pressed.connect(_on_recipe_rarity_pressed.bind("rare"))
	_recipe_unique_button.pressed.connect(_on_recipe_rarity_pressed.bind("unique"))
	_recipe_legendary_button.pressed.connect(_on_recipe_rarity_pressed.bind("legendary"))
	_recipe_transcendent_button.pressed.connect(_on_recipe_rarity_pressed.bind("transcendent"))
	_recipe_immortal_button.pressed.connect(_on_recipe_rarity_pressed.bind("immortal"))
	_recipe_god_button.pressed.connect(_on_recipe_rarity_pressed.bind("god"))
	_recipe_liberator_button.pressed.connect(_on_recipe_rarity_pressed.bind("liberator"))
	_easy_button.pressed.connect(_on_difficulty_pressed.bind("easy"))
	_normal_button.pressed.connect(_on_difficulty_pressed.bind("normal"))
	_hard_button.pressed.connect(_on_difficulty_pressed.bind("hard"))
	_story_slot_1.pressed.connect(_on_story_slot_pressed.bind(0))
	_story_slot_2.pressed.connect(_on_story_slot_pressed.bind(1))
	_story_slot_3.pressed.connect(_on_story_slot_pressed.bind(2))
	_unit_recipe_tooltip.set_as_top_level(true)
	_unit_recipe_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_unit_recipe_tooltip.z_index = 100
	var merge_panel: PanelContainer = $MergePanel
	merge_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	merge_panel.anchor_left = 0.5
	merge_panel.anchor_right = 0.5
	merge_panel.anchor_top = 1.0
	merge_panel.anchor_bottom = 1.0
	merge_panel.offset_left = -430.0
	merge_panel.offset_top = -174.0
	merge_panel.offset_right = 430.0
	merge_panel.offset_bottom = -18.0
	_unit_info_panel.custom_minimum_size = Vector2(0, 220)
	var tooltip_vbox: VBoxContainer = _unit_recipe_tooltip.get_node("MarginContainer/VBoxContainer")
	_unit_recipe_tooltip_formula_flow = HFlowContainer.new()
	_unit_recipe_tooltip_formula_flow.name = "TooltipFormulaFlow"
	_unit_recipe_tooltip_formula_flow.add_theme_constant_override("h_separation", 4)
	_unit_recipe_tooltip_formula_flow.add_theme_constant_override("v_separation", 2)
	tooltip_vbox.add_child(_unit_recipe_tooltip_formula_flow)
	tooltip_vbox.move_child(_unit_recipe_tooltip_formula_flow, 1)
	_bottom_shop_button.text = "상점"
	_bottom_mission_button.text = "임무"
	_bottom_recipe_button.text = "도감"
	_bottom_forge_button.text = "대장간"
	_bottom_title_label.visible = false
	_merge_hint_label.visible = false
	_shop_content_label.visible = false
	_quest_content_label.visible = false
	_forge_content_label.visible = false
	_merge_options.visible = false
	_mission_panel.visible = false
	_storage_help_label.visible = false
	_build_storage_tabs()
	_detach_selected_unit_panel()
	_build_modal_overlays()
	_build_pause_menu_overlay()
	_build_settings_overlay()
	AppSettings.language_changed.connect(_on_language_changed)
	_apply_localized_texts()


func _detach_selected_unit_panel() -> void:
	var unit_panel_parent: Node = _unit_info_panel.get_parent()
	if unit_panel_parent != self:
		unit_panel_parent.remove_child(_unit_info_panel)
		add_child(_unit_info_panel)
	_unit_info_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_unit_info_panel.anchor_left = 0.5
	_unit_info_panel.anchor_right = 0.5
	_unit_info_panel.anchor_top = 1.0
	_unit_info_panel.anchor_bottom = 1.0
	_unit_info_panel.offset_left = -430.0
	_unit_info_panel.offset_top = -248.0
	_unit_info_panel.offset_right = 430.0
	_unit_info_panel.offset_bottom = -18.0
	_unit_info_panel.size_flags_horizontal = Control.SIZE_FILL
	_unit_info_panel.z_index = 50
	var opaque_style := StyleBoxFlat.new()
	opaque_style.bg_color = Color(0.08, 0.1, 0.12, 1.0)
	opaque_style.border_color = Color(0.24, 0.28, 0.34, 1.0)
	opaque_style.border_width_left = 1
	opaque_style.border_width_top = 1
	opaque_style.border_width_right = 1
	opaque_style.border_width_bottom = 1
	opaque_style.corner_radius_top_left = 8
	opaque_style.corner_radius_top_right = 8
	opaque_style.corner_radius_bottom_left = 8
	opaque_style.corner_radius_bottom_right = 8
	_unit_info_panel.add_theme_stylebox_override("panel", opaque_style)

	var tooltip_parent: Node = _unit_recipe_tooltip.get_parent()
	if tooltip_parent != self:
		tooltip_parent.remove_child(_unit_recipe_tooltip)
		add_child(_unit_recipe_tooltip)
	_unit_recipe_tooltip.set_as_top_level(true)
	_unit_recipe_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_unit_recipe_tooltip.z_index = 100


func _build_storage_tabs() -> void:
	if _storage_tab_bar != null:
		return
	_storage_tab_bar = HBoxContainer.new()
	_storage_tab_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	_storage_tab_bar.add_theme_constant_override("separation", 4)
	_sidebar_vbox.add_child(_storage_tab_bar)
	_sidebar_vbox.move_child(_storage_tab_bar, 1)
	for rarity_id: String in ["", "common", "rare", "unique", "legendary", "transcendent", "immortal", "god", "liberator"]:
		var filter_button := Button.new()
		filter_button.focus_mode = Control.FOCUS_NONE
		filter_button.custom_minimum_size = Vector2(56, 28)
		filter_button.text = "ALL" if rarity_id.is_empty() else rarity_id.capitalize()
		filter_button.pressed.connect(_on_storage_rarity_filter_pressed.bind(rarity_id))
		_storage_tab_bar.add_child(filter_button)
		_storage_filter_buttons[rarity_id] = filter_button


func _on_storage_rarity_filter_pressed(rarity_id: String) -> void:
	_storage_rarity_filter = rarity_id
	_populate_storage_grid()


func _on_language_changed(_language_code: String) -> void:
	_apply_localized_texts()
	refresh()


func _apply_localized_texts() -> void:
	_bottom_shop_button.text = AppSettings.translate_key("shop")
	_bottom_mission_button.text = AppSettings.translate_key("mission")
	_bottom_recipe_button.text = AppSettings.translate_key("codex")
	_bottom_forge_button.text = AppSettings.translate_key("forge")
	$StatusPanel/MarginContainer/VBoxContainer/TitleLabel.text = AppSettings.translate_key("stage_control") if AppSettings.TRANSLATIONS.get(AppSettings.get_language_code(), {}).has("stage_control") else "Stage Control"
	$StoryPanel/MarginContainer/VBoxContainer/TitleLabel.text = AppSettings.translate_key("story_boss") if AppSettings.TRANSLATIONS.get(AppSettings.get_language_code(), {}).has("story_boss") else "Story Boss"
	$Sidebar/MarginContainer/VBoxContainer/StorageTitleLabel.text = AppSettings.translate_key("storage") if AppSettings.TRANSLATIONS.get(AppSettings.get_language_code(), {}).has("storage") else "Storage"
	for rarity_id: String in _storage_filter_buttons.keys():
		var filter_button: Button = _storage_filter_buttons[rarity_id]
		filter_button.text = AppSettings.translate_key("all") if rarity_id.is_empty() else AppSettings.translate_key(rarity_id)
	if _pause_overlay != null:
		_pause_title_label.text = AppSettings.translate_key("menu")
		_pause_back_button.text = AppSettings.translate_key("back")
		_pause_settings_button.text = AppSettings.translate_key("settings")
		_pause_quit_button.text = AppSettings.translate_key("quit")
	if _settings_overlay != null:
		_settings_title_label.text = AppSettings.translate_key("settings")
		_settings_reset_button.text = AppSettings.translate_key("reset")
		_settings_apply_button.text = AppSettings.translate_key("apply")
		_settings_cancel_button.text = AppSettings.translate_key("cancel")
		_settings_tab_container.set_tab_title(0, AppSettings.translate_key("display"))
		_settings_tab_container.set_tab_title(1, AppSettings.translate_key("audio"))
		_settings_tab_container.set_tab_title(2, AppSettings.translate_key("language"))
		_settings_tab_container.set_tab_title(3, AppSettings.translate_key("creator"))
		_refresh_settings_static_labels()


func _build_pause_menu_overlay() -> void:
	_pause_overlay = Control.new()
	_pause_overlay.visible = false
	_pause_overlay.anchors_preset = Control.PRESET_FULL_RECT
	_pause_overlay.anchor_right = 1.0
	_pause_overlay.anchor_bottom = 1.0
	_pause_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_pause_overlay)

	var dim := ColorRect.new()
	dim.anchors_preset = Control.PRESET_FULL_RECT
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	dim.color = Color(0, 0, 0, 0.78)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	dim.gui_input.connect(_on_pause_dim_input)
	_pause_overlay.add_child(dim)

	var center := CenterContainer.new()
	center.anchors_preset = Control.PRESET_FULL_RECT
	center.anchor_right = 1.0
	center.anchor_bottom = 1.0
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pause_overlay.add_child(center)

	_pause_panel = PanelContainer.new()
	_pause_panel.custom_minimum_size = Vector2(320, 260)
	_pause_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	center.add_child(_pause_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	_pause_panel.add_child(margin)

	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	margin.add_child(body)

	_pause_title_label = Label.new()
	_pause_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(_pause_title_label)

	_pause_back_button = Button.new()
	_pause_back_button.custom_minimum_size = Vector2(0, 42)
	_pause_back_button.pressed.connect(_on_pause_back_pressed)
	body.add_child(_pause_back_button)

	_pause_settings_button = Button.new()
	_pause_settings_button.custom_minimum_size = Vector2(0, 42)
	_pause_settings_button.pressed.connect(_on_pause_settings_pressed)
	body.add_child(_pause_settings_button)

	_pause_quit_button = Button.new()
	_pause_quit_button.custom_minimum_size = Vector2(0, 42)
	_pause_quit_button.pressed.connect(_on_pause_quit_pressed)
	body.add_child(_pause_quit_button)


func _build_settings_overlay() -> void:
	_settings_overlay = Control.new()
	_settings_overlay.visible = false
	_settings_overlay.anchors_preset = Control.PRESET_FULL_RECT
	_settings_overlay.anchor_right = 1.0
	_settings_overlay.anchor_bottom = 1.0
	_settings_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_settings_overlay)

	var dim := ColorRect.new()
	dim.anchors_preset = Control.PRESET_FULL_RECT
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	dim.color = Color(0, 0, 0, 0.82)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_settings_overlay.add_child(dim)

	var center := CenterContainer.new()
	center.anchors_preset = Control.PRESET_FULL_RECT
	center.anchor_right = 1.0
	center.anchor_bottom = 1.0
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_settings_overlay.add_child(center)

	_settings_panel = PanelContainer.new()
	_settings_panel.custom_minimum_size = Vector2(980, 700)
	_settings_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	center.add_child(_settings_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	_settings_panel.add_child(margin)

	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	margin.add_child(body)

	var header := HBoxContainer.new()
	body.add_child(header)

	_settings_title_label = Label.new()
	_settings_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_settings_title_label)

	var close_button := Button.new()
	close_button.custom_minimum_size = Vector2(90, 36)
	close_button.text = "X"
	close_button.pressed.connect(_close_settings_overlay)
	header.add_child(close_button)

	_settings_tab_container = TabContainer.new()
	_settings_tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(_settings_tab_container)

	_build_display_tab()
	_build_audio_tab()
	_build_language_tab()
	_build_creator_tab()

	var action_row := HBoxContainer.new()
	action_row.alignment = BoxContainer.ALIGNMENT_END
	action_row.add_theme_constant_override("separation", 8)
	body.add_child(action_row)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_row.add_child(spacer)

	_settings_reset_button = Button.new()
	_settings_reset_button.custom_minimum_size = Vector2(90, 36)
	_settings_reset_button.pressed.connect(_on_settings_reset_pressed)
	action_row.add_child(_settings_reset_button)

	_settings_apply_button = Button.new()
	_settings_apply_button.custom_minimum_size = Vector2(90, 36)
	_settings_apply_button.pressed.connect(_on_settings_apply_pressed)
	action_row.add_child(_settings_apply_button)

	_settings_cancel_button = Button.new()
	_settings_cancel_button.custom_minimum_size = Vector2(90, 36)
	_settings_cancel_button.pressed.connect(_on_settings_cancel_pressed)
	action_row.add_child(_settings_cancel_button)

	_settings_pending = AppSettings.get_settings_copy()
	_populate_settings_controls_from_pending()
	_refresh_settings_buttons()


func _build_display_tab() -> void:
	var tab := VBoxContainer.new()
	tab.name = "display"
	tab.add_theme_constant_override("separation", 12)
	_settings_tab_container.add_child(tab)

	var label := Label.new()
	label.name = "ResolutionLabel"
	tab.add_child(label)

	_settings_resolution_option = OptionButton.new()
	for resolution in ["1280x720", "1600x900", "1920x1080", "2560x1440"]:
		_settings_resolution_option.add_item(resolution)
	_settings_resolution_option.item_selected.connect(_on_settings_control_changed)
	tab.add_child(_settings_resolution_option)


func _build_audio_tab() -> void:
	var scroll := ScrollContainer.new()
	scroll.name = "audio"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_settings_tab_container.add_child(scroll)

	var tab := VBoxContainer.new()
	tab.add_theme_constant_override("separation", 12)
	scroll.add_child(tab)

	for item in [["master", "master_volume"], ["character", "character_volume"], ["music", "music_volume"], ["ambient", "ambient_volume"]]:
		var key_prefix: String = item[0]
		var label_key: String = item[1]
		var section := VBoxContainer.new()
		section.add_theme_constant_override("separation", 6)
		tab.add_child(section)
		var label := Label.new()
		label.name = "%s_label" % key_prefix
		section.add_child(label)
		var slider := HSlider.new()
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.01
		slider.value_changed.connect(_on_settings_control_changed.bind())
		section.add_child(slider)
		var mute := CheckBox.new()
		mute.toggled.connect(_on_settings_control_changed.bind())
		section.add_child(mute)
		_settings_audio_controls[key_prefix] = {
			"label": label,
			"label_key": label_key,
			"slider": slider,
			"mute": mute,
		}


func _build_language_tab() -> void:
	var tab := VBoxContainer.new()
	tab.name = "language"
	tab.add_theme_constant_override("separation", 12)
	_settings_tab_container.add_child(tab)

	var label := Label.new()
	label.name = "LanguageLabel"
	tab.add_child(label)

	_settings_language_option = OptionButton.new()
	_settings_language_option.add_item("English", 0)
	_settings_language_option.add_item("Korean", 1)
	_settings_language_option.item_selected.connect(_on_settings_control_changed)
	tab.add_child(_settings_language_option)


func _build_creator_tab() -> void:
	var tab := VBoxContainer.new()
	tab.name = "creator"
	_settings_tab_container.add_child(tab)
	var label := Label.new()
	label.name = "CreatorLabel"
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tab.add_child(label)


func _refresh_settings_static_labels() -> void:
	if _settings_tab_container == null:
		return
	var display_tab: VBoxContainer = _settings_tab_container.get_node("display")
	display_tab.get_node("ResolutionLabel").text = AppSettings.translate_key("resolution")
	for key_prefix: String in _settings_audio_controls.keys():
		var item: Dictionary = _settings_audio_controls[key_prefix]
		item.get("label").text = AppSettings.translate_key(str(item.get("label_key", "")))
		item.get("mute").text = AppSettings.translate_key("mute")
	var language_tab: VBoxContainer = _settings_tab_container.get_node("language")
	language_tab.get_node("LanguageLabel").text = AppSettings.translate_key("language")
	_settings_language_option.set_item_text(0, AppSettings.translate_key("english"))
	_settings_language_option.set_item_text(1, AppSettings.translate_key("korean"))
	var creator_tab: VBoxContainer = _settings_tab_container.get_node("creator")
	creator_tab.get_node("CreatorLabel").text = AppSettings.translate_key("creator_placeholder")


func _open_pause_overlay() -> void:
	_pause_overlay.visible = true


func _close_pause_overlay() -> void:
	_pause_overlay.visible = false


func _open_settings_overlay() -> void:
	_settings_pending = AppSettings.get_settings_copy()
	_populate_settings_controls_from_pending()
	_refresh_settings_buttons()
	_settings_overlay.visible = true


func _close_settings_overlay() -> void:
	_settings_overlay.visible = false


func _populate_settings_controls_from_pending() -> void:
	_is_updating_settings_controls = true
	var display_settings: Dictionary = _settings_pending.get("display", {})
	var resolution: String = str(display_settings.get("resolution", "1600x900"))
	for index in range(_settings_resolution_option.item_count):
		if _settings_resolution_option.get_item_text(index) == resolution:
			_settings_resolution_option.select(index)
			break
	var audio_settings: Dictionary = _settings_pending.get("audio", {})
	for key_prefix: String in _settings_audio_controls.keys():
		var item: Dictionary = _settings_audio_controls.get(key_prefix, {})
		(item.get("slider") as HSlider).value = float(audio_settings.get("%s_volume" % key_prefix, 1.0))
		(item.get("mute") as CheckBox).button_pressed = bool(audio_settings.get("%s_mute" % key_prefix, false))
	var language_code: String = str(_settings_pending.get("language", {}).get("code", "ko"))
	_settings_language_option.select(0 if language_code == "en" else 1)
	_is_updating_settings_controls = false


func _snapshot_pending_from_controls() -> void:
	if _is_updating_settings_controls:
		return
	_settings_pending["display"]["resolution"] = _settings_resolution_option.get_item_text(_settings_resolution_option.selected)
	for key_prefix: String in _settings_audio_controls.keys():
		var item: Dictionary = _settings_audio_controls.get(key_prefix, {})
		_settings_pending["audio"]["%s_volume" % key_prefix] = float((item.get("slider") as HSlider).value)
		_settings_pending["audio"]["%s_mute" % key_prefix] = bool((item.get("mute") as CheckBox).button_pressed)
	_settings_pending["language"]["code"] = "en" if _settings_language_option.selected == 0 else "ko"
	_refresh_settings_buttons()


func _settings_is_dirty() -> bool:
	return JSON.stringify(_settings_pending) != JSON.stringify(AppSettings.get_settings_copy())


func _refresh_settings_buttons() -> void:
	var is_dirty: bool = _settings_is_dirty()
	_settings_apply_button.disabled = not is_dirty
	_settings_cancel_button.disabled = not is_dirty


func _on_pause_back_pressed() -> void:
	_close_pause_overlay()


func _on_pause_settings_pressed() -> void:
	_close_pause_overlay()
	_open_settings_overlay()


func _on_pause_quit_pressed() -> void:
	get_tree().quit()


func _on_pause_dim_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not _pause_panel.get_global_rect().has_point(get_viewport().get_mouse_position()):
			_close_pause_overlay()
			get_viewport().set_input_as_handled()


func _on_settings_control_changed(_value = null) -> void:
	_snapshot_pending_from_controls()


func _on_settings_apply_pressed() -> void:
	_snapshot_pending_from_controls()
	AppSettings.apply_settings(_settings_pending)
	_settings_pending = AppSettings.get_settings_copy()
	_populate_settings_controls_from_pending()
	_refresh_settings_buttons()


func _on_settings_cancel_pressed() -> void:
	_settings_pending = AppSettings.get_settings_copy()
	_populate_settings_controls_from_pending()
	_refresh_settings_buttons()


func _on_settings_reset_pressed() -> void:
	var current_settings: Dictionary = AppSettings.get_settings_copy()
	var defaults: Dictionary = AppSettings.get_default_settings_copy()
	var category: String = str(_settings_tab_container.get_current_tab_control().name)
	current_settings[category] = defaults.get(category, {}).duplicate(true)
	AppSettings.apply_settings(current_settings)
	_settings_pending = AppSettings.get_settings_copy()
	_populate_settings_controls_from_pending()
	_refresh_settings_buttons()


func refresh() -> void:
	_refresh_live_state()
	_refresh_story_buttons()
	_refresh_mission_buttons()
	_populate_storage_grid()
	_refresh_selected_unit_panel()
	_refresh_bottom_panel()
	if _recipe_overlay.visible:
		_refresh_recipe_browser()
	if _shop_overlay != null and _shop_overlay.visible:
		_refresh_shop_overlay()
	if _mission_overlay != null and _mission_overlay.visible:
		_refresh_mission_overlay()
	if _forge_overlay != null and _forge_overlay.visible:
		_refresh_forge_overlay()


func refresh_live() -> void:
	_refresh_live_state()


func refresh_selection_only() -> void:
	_selected_label.text = _selected_unit_text()
	_move_to_storage_button.visible = not GameState.get_selected_story_unit().is_empty() or not GameState.get_selected_board_unit().is_empty()
	_move_to_storage_button.disabled = not GameState.has_storage_space()
	_refresh_story_buttons()
	_populate_storage_grid()
	_refresh_selected_unit_panel()
	_refresh_bottom_panel()
	if _recipe_overlay.visible:
		_refresh_recipe_browser()
	if _shop_overlay != null and _shop_overlay.visible:
		_refresh_shop_overlay()
	if _mission_overlay != null and _mission_overlay.visible:
		_refresh_mission_overlay()
	if _forge_overlay != null and _forge_overlay.visible:
		_refresh_forge_overlay()


func _refresh_live_state() -> void:
	_round_label.text = GameState.get_round_label_text()
	_timer_label.text = GameState.get_next_round_timer_text()
	_leak_label.text = "Enemies %d / %d" % [GameState.get_active_enemies().size(), GameState.get_current_active_enemy_limit()]
	_gold_label.text = "Gold %d" % GameState.current_gold
	_storage_label.text = "Storage %d" % GameState.storage_count
	_speed_normal_button.disabled = is_equal_approx(current_speed_multiplier, 1.0)
	_speed_15_button.disabled = is_equal_approx(current_speed_multiplier, 1.5)
	_speed_20_button.disabled = is_equal_approx(current_speed_multiplier, 2.0)
	_move_to_storage_button.visible = not GameState.get_selected_story_unit().is_empty() or not GameState.get_selected_board_unit().is_empty()
	_move_to_storage_button.disabled = not GameState.has_storage_space()
	_enemy_label.text = "Enemies %d active | %d queued" % [GameState.get_active_enemies().size(), GameState.pending_spawn_count]
	_combat_label.text = "Combat %d attacks | %d defeated | %d round gold" % [
		GameState.total_attack_count_this_round,
		GameState.defeated_enemy_count_this_round,
		GameState.round_gold_earned,
	]
	_selected_label.text = _selected_unit_text()
	_status_label.text = GameState.status_message
	_start_round_button.visible = false
	_start_round_button.disabled = true
	_restart_run_button.visible = GameState.game_over
	_difficulty_panel.visible = not GameState.difficulty_selected
	_refresh_top_center_overlay()
	_refresh_story_live_panel()


func _refresh_top_center_overlay() -> void:
	$TopCenterOverlay.visible = GameState.difficulty_selected and not GameState.game_over
	if not $TopCenterOverlay.visible:
		return

	var countdown_seconds: int = GameState.get_next_round_countdown_seconds()
	var minute_value: int = countdown_seconds / 60
	var second_value: int = countdown_seconds % 60
	var pulse: float = 0.85 + 0.15 * sin(Time.get_ticks_msec() / 120.0)

	_countdown_caption_label.text = "NEXT ROUND"
	_countdown_value_label.text = "%02d:%02d" % [minute_value, second_value]
	_countdown_caption_label.modulate = Color(0.88, 0.9, 0.94, 0.9)
	_countdown_value_label.modulate = Color(0.95, 0.97, 0.99, 0.96)
	_countdown_value_label.scale = Vector2.ONE

	if GameState.difficulty_selected and countdown_seconds <= 10:
		_countdown_caption_label.text = "ROUND START"
		_countdown_caption_label.modulate = Color(1.0, 0.82, 0.34, 0.95)
		_countdown_value_label.modulate = Color(1.0, 0.9, 0.46, pulse)
		_countdown_value_label.scale = Vector2(1.08, 1.08)

	_enemy_warning_label.text = GameState.get_field_enemy_warning_text()
	if GameState.is_field_enemy_warning_active():
		_enemy_warning_label.modulate = Color(1.0, 0.24, 0.24, pulse)
		_enemy_warning_label.scale = Vector2(1.06, 1.06)
	else:
		_enemy_warning_label.modulate = Color(0.85, 0.88, 0.92, 0.82)
		_enemy_warning_label.scale = Vector2.ONE

	var boss_warning_text: String = GameState.get_upcoming_boss_warning_text()
	_boss_warning_label.text = boss_warning_text
	_boss_warning_label.visible = not boss_warning_text.is_empty()
	if _boss_warning_label.visible:
		_boss_warning_label.modulate = Color(1.0, 0.36, 0.22, pulse)
		_boss_warning_label.scale = Vector2(1.05, 1.05)


func _populate_storage_grid() -> void:
	for child in _storage_grid.get_children():
		child.queue_free()

	_storage_grid.columns = STORAGE_GRID_COLUMNS

	var selected_unit: Dictionary = GameState.get_selected_storage_unit()
	var selected_instance_id: String = str(selected_unit.get("instance_id", ""))
	var groups: Array[Dictionary] = GameState.get_storage_groups()
	for rarity_id: String in _storage_filter_buttons.keys():
		var filter_button: Button = _storage_filter_buttons[rarity_id]
		filter_button.disabled = rarity_id == _storage_rarity_filter

	for group: Dictionary in groups:
		if not _storage_rarity_filter.is_empty() and str(group.get("rarity", "")) != _storage_rarity_filter:
			continue
		var slot_button := Button.new()
		slot_button.custom_minimum_size = Vector2(72, 92)
		slot_button.tooltip_text = _storage_group_tooltip(group)
		slot_button.focus_mode = Control.FOCUS_NONE
		slot_button.clip_contents = true

		var slot_center := CenterContainer.new()
		slot_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot_center.anchors_preset = Control.PRESET_FULL_RECT
		slot_center.offset_left = 2
		slot_center.offset_top = 2
		slot_center.offset_right = -2
		slot_center.offset_bottom = -2
		slot_button.add_child(slot_center)

		var slot_content := VBoxContainer.new()
		slot_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot_content.alignment = BoxContainer.ALIGNMENT_CENTER
		slot_content.add_theme_constant_override("separation", 1)
		slot_content.custom_minimum_size = Vector2(66, 84)
		slot_center.add_child(slot_content)

		var icon_center := CenterContainer.new()
		icon_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_center.custom_minimum_size = Vector2(66, 52)
		slot_content.add_child(icon_center)

		var icon_rect := TextureRect.new()
		icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_rect.custom_minimum_size = Vector2(48, 48)
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.texture = ActorViewFactory.create_unit_icon_texture(group.get("representative_unit", {}))
		icon_center.add_child(icon_rect)

		var name_label := Label.new()
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		name_label.custom_minimum_size = Vector2(66, 0)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		name_label.add_theme_font_size_override("font_size", 12)
		name_label.text = _storage_short_name(str(group.get("display_name", "Unit")))
		slot_content.add_child(name_label)

		var count_label := Label.new()
		count_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		count_label.custom_minimum_size = Vector2(66, 0)
		count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		count_label.add_theme_font_size_override("font_size", 12)
		count_label.text = "x%d" % int(group.get("count", 0))
		slot_content.add_child(count_label)

		var instance_ids: Array = group.get("instance_ids", [])
		var is_selected := selected_instance_id in instance_ids
		if is_selected:
			slot_button.modulate = Color(1.0, 0.92, 0.7, 1.0)
		else:
			slot_button.modulate = Color(1.0, 1.0, 1.0, 1.0)

		slot_button.pressed.connect(_on_storage_group_pressed.bind(str(group.get("representative_instance_id", ""))))
		_storage_grid.add_child(slot_button)



func _refresh_story_live_panel() -> void:
	var story_state: Dictionary = GameState.get_story_boss_state()
	_story_stage_label.text = "Stage %d - %s" % [int(story_state.get("stage", 1)), str(story_state.get("display_name", "Story Boss"))]
	_story_hp_bar.max_value = max(1.0, float(story_state.get("max_hp", 1)))
	_story_hp_bar.value = float(story_state.get("current_hp", 0))
	_story_hp_label.text = "%d / %d" % [int(story_state.get("current_hp", 0)), int(story_state.get("max_hp", 1))]


func _refresh_story_buttons() -> void:

	var story_slots: Array[Dictionary] = GameState.get_story_slots()
	var buttons := [_story_slot_1, _story_slot_2, _story_slot_3]
	for index in range(buttons.size()):
		_populate_story_slot_button(buttons[index], story_slots[index], index == GameState.selected_story_slot_index)


func _refresh_mission_buttons() -> void:
	for child in _mission_buttons.get_children():
		child.queue_free()

	for mission_state: Dictionary in GameState.get_mission_boss_states():
		var mission_button := Button.new()
		var unlocked: bool = bool(mission_state.get("unlocked", false))
		var cooldown_remaining: float = float(mission_state.get("cooldown_remaining", 0.0))
		var mission_id: String = str(mission_state.get("id", ""))
		mission_button.focus_mode = Control.FOCUS_NONE
		if not unlocked:
			mission_button.text = "%s (Locked)" % mission_id
			mission_button.disabled = true
		elif cooldown_remaining > 0.0:
			mission_button.text = "%s (%ds)" % [mission_id, int(ceil(cooldown_remaining))]
			mission_button.disabled = true
		else:
			mission_button.text = "%s Summon" % mission_id
			mission_button.disabled = false
			mission_button.pressed.connect(_on_mission_boss_pressed.bind(mission_id))
		_mission_buttons.add_child(mission_button)


func _storage_group_text(group: Dictionary) -> String:
	return "%s\nx%d" % [
		_storage_short_name(str(group.get("display_name", "Unit"))),
		int(group.get("count", 0)),
	]


func _storage_group_tooltip(group: Dictionary) -> String:
	return "%s [%s] x%d" % [
		str(group.get("display_name", "Unit")),
		str(group.get("rarity", "common")),
		int(group.get("count", 0)),
	]


func _storage_short_name(display_name: String) -> String:
	var parts: PackedStringArray = display_name.split(" ", false)
	if parts.size() <= 1:
		return display_name
	return "%s %s" % [parts[0], parts[1]]


func _populate_story_slot_button(button: Button, slot: Dictionary, is_selected: bool) -> void:
	for child in button.get_children():
		child.queue_free()

	var unit: Variant = slot.get("unit")
	button.expand_icon = true
	button.icon = null
	button.text = ""

	var content := VBoxContainer.new()
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.anchors_preset = Control.PRESET_FULL_RECT
	content.offset_left = 4
	content.offset_top = 4
	content.offset_right = -4
	content.offset_bottom = -4
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 1)
	button.add_child(content)

	if unit == null:
		var empty_label := Label.new()
		empty_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.text = "Empty"
		content.add_child(empty_label)
	else:
		var icon_rect := TextureRect.new()
		icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_rect.custom_minimum_size = Vector2(42, 42)
		icon_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.texture = ActorViewFactory.create_unit_icon_texture(unit)
		content.add_child(icon_rect)

		var name_label := Label.new()
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		name_label.add_theme_font_size_override("font_size", 12)
		name_label.text = _storage_short_name(str(unit.get("display_name", "Unit")))
		content.add_child(name_label)

	button.modulate = Color(1.0, 0.92, 0.7, 1.0) if is_selected else Color(1.0, 1.0, 1.0, 1.0)


func _selected_unit_text() -> String:
	var selected_unit: Dictionary = GameState.get_selected_unit()
	if selected_unit.is_empty():
		return "Selected: none"

	return "Selected: %s [%s]" % [
		str(selected_unit.get("display_name", "Unit")),
		str(selected_unit.get("rarity", "common")),
	]


func _refresh_selected_unit_panel() -> void:
	var selected_unit: Dictionary = GameState.get_selected_unit()
	_unit_info_panel.visible = not selected_unit.is_empty()
	_unit_recipe_tooltip.visible = false
	if selected_unit.is_empty():
		return

	var snapshot: Dictionary = GameState.get_unit_combat_snapshot(selected_unit)
	var damage_type: String = str(snapshot.get("damage_type", "physical"))
	var damage_value: float = float(snapshot.get("damage", 0.0))
	var attack_speed_value: float = float(snapshot.get("attack_speed", 1.0))

	_unit_info_name_label.text = str(selected_unit.get("display_name", "Unit"))
	_unit_info_icon.texture = ActorViewFactory.create_unit_icon_texture(selected_unit)
	_unit_info_grade_label.text = "등급: %s" % str(snapshot.get("rarity", selected_unit.get("rarity", "common")))
	_unit_info_strength_label.text = "힘: %d" % int(snapshot.get("strength", 0))
	_unit_info_damage_label.text = "%s: %d" % ["물리 피해" if damage_type == "physical" else "마법 피해", int(round(damage_value))]
	_unit_info_agility_label.text = "민첩: %d" % int(snapshot.get("agility", 0))
	_unit_info_attack_speed_label.text = "공속: %.2f" % attack_speed_value
	_unit_info_intelligence_label.text = "지능: %d" % int(snapshot.get("intelligence", 0))
	_unit_info_skill_label.text = "추후 추가 예정"

	for child in _unit_info_recipe_cards.get_children():
		child.queue_free()

	var recipes: Array[Dictionary] = GameState.get_recipes_using_unit(str(selected_unit.get("definition_id", "")))
	if recipes.is_empty():
		var empty_label := Label.new()
		empty_label.text = "조합식 없음"
		_unit_info_recipe_cards.add_child(empty_label)
		return

	recipes.sort_custom(func(a: Dictionary, b: Dictionary): return str(a.get("output_display_name", "")) < str(b.get("output_display_name", "")))
	for recipe: Dictionary in recipes:
		var recipe_card := _create_recipe_output_card(recipe)
		recipe_card.mouse_entered.connect(_show_unit_recipe_tooltip.bind(recipe, recipe_card))
		recipe_card.mouse_exited.connect(_hide_unit_recipe_tooltip)
		_unit_info_recipe_cards.add_child(recipe_card)


func _create_recipe_output_card(recipe: Dictionary) -> Control:
	var output_unit_id: String = str(recipe.get("output_unit_id", ""))
	var output_definition: Dictionary = GameState.get_unit_definition(output_unit_id)
	var can_craft: bool = _can_craft_recipe_with_owned_units(recipe)
	var recipe_card := Button.new()
	recipe_card.text = ""
	recipe_card.mouse_filter = Control.MOUSE_FILTER_STOP
	recipe_card.focus_mode = Control.FOCUS_NONE
	recipe_card.custom_minimum_size = Vector2(52, 56)
	recipe_card.tooltip_text = str(recipe.get("output_display_name", _recipe_output_name(recipe)))
	recipe_card.modulate = Color(1.0, 1.0, 1.0, 1.0) if can_craft else Color(0.42, 0.42, 0.46, 1.0)
	recipe_card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if can_craft else Control.CURSOR_ARROW
	if can_craft:
		recipe_card.pressed.connect(_on_merge_pressed.bind(str(recipe.get("id", ""))))

	var card_center := CenterContainer.new()
	card_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_center.anchors_preset = Control.PRESET_FULL_RECT
	card_center.offset_left = 2
	card_center.offset_top = 2
	card_center.offset_right = -2
	card_center.offset_bottom = -2
	recipe_card.add_child(card_center)

	var content := VBoxContainer.new()
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 1)
	content.custom_minimum_size = Vector2(46, 52)
	card_center.add_child(content)

	var icon_center := CenterContainer.new()
	icon_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_center.custom_minimum_size = Vector2(46, 28)
	content.add_child(icon_center)

	var icon := TextureRect.new()
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.custom_minimum_size = Vector2(24, 24)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = ActorViewFactory.create_unit_icon_texture(output_definition)
	icon_center.add_child(icon)

	var name_label := Label.new()
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.custom_minimum_size = Vector2(46, 0)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.text = _storage_short_name(str(recipe.get("output_display_name", _recipe_output_name(recipe))))
	content.add_child(name_label)

	return recipe_card


func _can_craft_recipe_with_owned_units(recipe: Dictionary) -> bool:
	var owned_counts: Dictionary = GameState.get_owned_unit_counts()
	for input: Dictionary in recipe.get("inputs", []):
		var unit_id: String = str(input.get("unit_id", ""))
		var required_count: int = int(input.get("count", 0))
		if int(owned_counts.get(unit_id, 0)) < required_count:
			return false
	return true


func _add_tooltip_formula_token(flow: HFlowContainer, token_text: String, token_color: Color) -> void:
	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = token_text
	label.modulate = token_color
	flow.add_child(label)


func _refresh_bottom_panel() -> void:
	_bottom_shop_button.disabled = false
	_bottom_mission_button.disabled = false
	_bottom_recipe_button.disabled = false
	_bottom_forge_button.disabled = false
	_bottom_title_label.visible = false
	_merge_hint_label.visible = false
	_merge_options.visible = false
	_shop_content_label.visible = false
	_quest_content_label.visible = false
	_forge_content_label.visible = false


func _populate_merge_options() -> void:
	for child in _merge_options.get_children():
		child.queue_free()

	var merge_options: Array[Dictionary] = GameState.get_merge_recipe_options()
	_merge_options.visible = true
	_merge_hint_label.visible = true

	if not GameState.difficulty_selected:
		_merge_hint_label.text = "Select a difficulty to unlock merge and round flow."
		return

	if merge_options.is_empty():
		_merge_hint_label.text = "Select a storage stack or placed unit to see available recipes."
		return

	_merge_hint_label.text = "Available recipes for the current selection:"
	for recipe: Dictionary in merge_options:
		var recipe_button := Button.new()
		recipe_button.text = ""
		recipe_button.focus_mode = Control.FOCUS_NONE
		recipe_button.custom_minimum_size = Vector2(0, 56)
		recipe_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		recipe_button.clip_contents = true
		var can_craft: bool = bool(recipe.get("can_craft", false))
		recipe_button.disabled = not can_craft
		if not can_craft:
			recipe_button.modulate = Color(0.46, 0.46, 0.46, 0.95)
		else:
			recipe_button.modulate = Color(1, 1, 1, 1)
		_populate_recipe_button_content(recipe_button, recipe)
		recipe_button.pressed.connect(_on_merge_pressed.bind(str(recipe.get("id", ""))))
		_merge_options.add_child(recipe_button)


func _recipe_button_text(recipe: Dictionary) -> String:
	var inputs: Array[String] = []
	var owned_counts: Dictionary = GameState.get_owned_unit_counts()
	for input: Dictionary in recipe.get("inputs", []):
		var unit_name: String = GameState.get_unit_display_name(str(input.get("unit_id", "")))
		var count: int = int(input.get("count", 0))
		var owned_count: int = int(owned_counts.get(str(input.get("unit_id", "")), 0))
		var color: String = "#ffffff" if owned_count >= count else "#8c8f94"
		inputs.append("[color=%s]%s x%d[/color]" % [color, unit_name, count])

	return "%s = [color=#ffd166]%s[/color]" % [" + ".join(inputs), str(_recipe_output_name(recipe))]


func _recipe_button_plain_text(recipe: Dictionary) -> String:
	var inputs: Array[String] = []
	for input: Dictionary in recipe.get("inputs", []):
		var unit_name: String = GameState.get_unit_display_name(str(input.get("unit_id", "")))
		var count: int = int(input.get("count", 0))
		inputs.append("%s x%d" % [unit_name, count])

	return "%s = %s" % [" + ".join(inputs), str(_recipe_output_name(recipe))]


func _populate_recipe_button_content(button: Button, recipe: Dictionary) -> void:
	for child in button.get_children():
		child.queue_free()

	var owned_counts: Dictionary = GameState.get_owned_unit_counts()
	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.anchors_preset = Control.PRESET_FULL_RECT
	margin.offset_left = 10
	margin.offset_top = 6
	margin.offset_right = -10
	margin.offset_bottom = -6
	button.add_child(margin)

	var flow := HFlowContainer.new()
	flow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flow.alignment = FlowContainer.ALIGNMENT_BEGIN
	flow.add_theme_constant_override("h_separation", 4)
	flow.add_theme_constant_override("v_separation", 2)
	margin.add_child(flow)

	var inputs: Array = recipe.get("inputs", [])
	for index in range(inputs.size()):
		var input: Dictionary = inputs[index]
		var unit_id: String = str(input.get("unit_id", ""))
		var required_count: int = int(input.get("count", 0))
		var owned_count: int = int(owned_counts.get(unit_id, 0))
		var input_label := Label.new()
		input_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		input_label.text = "%s x%d" % [GameState.get_unit_display_name(unit_id), required_count]
		input_label.modulate = Color(1.0, 1.0, 1.0, 1.0) if owned_count >= required_count else Color(0.58, 0.6, 0.64, 1.0)
		flow.add_child(input_label)

		if index < inputs.size() - 1:
			var plus_label := Label.new()
			plus_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			plus_label.text = "+"
			plus_label.modulate = Color(0.82, 0.84, 0.9, 1.0)
			flow.add_child(plus_label)

	var equals_label := Label.new()
	equals_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	equals_label.text = "="
	equals_label.modulate = Color(0.82, 0.84, 0.9, 1.0)
	flow.add_child(equals_label)

	var output_label := Label.new()
	output_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	output_label.text = str(_recipe_output_name(recipe))
	output_label.modulate = Color(1.0, 0.82, 0.4, 1.0)
	flow.add_child(output_label)


func _recipe_output_name(recipe: Dictionary) -> String:
	var output_unit_id: String = str(recipe.get("output_unit_id", ""))
	return GameState.get_unit_display_name(output_unit_id)


func _on_storage_group_pressed(instance_id: String) -> void:
	storage_unit_selected.emit(instance_id)


func _on_story_slot_pressed(slot_index: int) -> void:
	story_slot_requested.emit(slot_index)


func _on_mission_boss_pressed(mission_id: String) -> void:
	mission_boss_requested.emit(mission_id)


func _on_merge_pressed(recipe_id: String) -> void:
	merge_requested.emit(recipe_id)


func _on_restart_run_pressed() -> void:
	restart_requested.emit()


func _on_difficulty_pressed(next_difficulty_id: String) -> void:
	difficulty_selected.emit(next_difficulty_id)


func _on_start_round_pressed() -> void:
	start_round_requested.emit()


func _on_move_to_storage_pressed() -> void:
	move_to_storage_requested.emit()


func _on_speed_pressed(multiplier: float) -> void:
	speed_requested.emit(multiplier)


func set_speed_multiplier(multiplier: float) -> void:
	current_speed_multiplier = multiplier
	_refresh_live_state()


func _on_bottom_tab_pressed(tab_id: String) -> void:
	_bottom_tab = tab_id
	_refresh_bottom_panel()


func _on_recipe_browser_open_pressed() -> void:
	_recipe_browser_rarity = "rare"
	_recipe_browser_filter_output_ids.clear()
	_recipe_overlay.visible = true
	_refresh_recipe_browser()


func _on_recipe_browser_close_pressed() -> void:
	_recipe_overlay.visible = false


func _on_recipe_overlay_input(event: InputEvent) -> void:
	if not _recipe_overlay.visible:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not _recipe_overlay_panel.get_global_rect().has_point(get_viewport().get_mouse_position()):
			_recipe_overlay.visible = false


func _on_recipe_overlay_dim_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_recipe_overlay.visible = false
		get_viewport().set_input_as_handled()


func _on_recipe_rarity_pressed(rarity: String) -> void:
	_recipe_browser_rarity = rarity
	_recipe_browser_filter_output_ids.clear()
	_refresh_recipe_browser()


func _refresh_recipe_browser() -> void:
	_recipe_all_button.disabled = _recipe_browser_rarity.is_empty()
	_recipe_rare_button.disabled = _recipe_browser_rarity == "rare"
	_recipe_unique_button.disabled = _recipe_browser_rarity == "unique"
	_recipe_legendary_button.disabled = _recipe_browser_rarity == "legendary"
	_recipe_transcendent_button.disabled = _recipe_browser_rarity == "transcendent"
	_recipe_immortal_button.disabled = _recipe_browser_rarity == "immortal"
	_recipe_god_button.disabled = _recipe_browser_rarity == "god"
	_recipe_liberator_button.disabled = _recipe_browser_rarity == "liberator"

	for child in _recipe_browser_list.get_children():
		child.queue_free()

	_recipe_overlay_title.text = "조합식"
	_recipe_browser_hint_label.text = "등급을 선택하고 조합식을 누르면 하위 재료 단계로 이동합니다."

	var entries: Array[Dictionary] = []
	if _recipe_browser_rarity.is_empty():
		for rarity_id in ["rare", "unique", "legendary", "transcendent", "immortal", "god", "liberator"]:
			entries.append_array(GameState.get_recipe_browser_entries(rarity_id, _recipe_browser_filter_output_ids))
	else:
		entries = GameState.get_recipe_browser_entries(_recipe_browser_rarity, _recipe_browser_filter_output_ids)

	if entries.is_empty():
		var empty_label := Label.new()
		empty_label.text = "표시할 조합식이 없습니다."
		_recipe_browser_list.add_child(empty_label)
		return

	for recipe: Dictionary in entries:
		var entry_panel := PanelContainer.new()
		entry_panel.custom_minimum_size = Vector2(0, 56)
		entry_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_populate_recipe_browser_entry(entry_panel, recipe)
		_recipe_browser_list.add_child(entry_panel)


func _on_recipe_browser_input_pressed(unit_id: String) -> void:
	var next_rarity: String = GameState.get_unit_rarity(unit_id)
	if next_rarity.is_empty() or next_rarity == "common":
		_recipe_browser_hint_label.text = "이 재료는 더 하위 조합식이 없습니다."
		return

	_recipe_browser_rarity = next_rarity
	_recipe_browser_filter_output_ids = [unit_id]
	_refresh_recipe_browser()


func _populate_recipe_browser_entry(container: Control, recipe: Dictionary) -> void:
	for child in container.get_children():
		child.queue_free()

	var owned_counts: Dictionary = GameState.get_owned_unit_counts()
	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.anchors_preset = Control.PRESET_FULL_RECT
	margin.offset_left = 8
	margin.offset_top = 6
	margin.offset_right = -8
	margin.offset_bottom = -6
	container.add_child(margin)

	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.anchors_preset = Control.PRESET_FULL_RECT
	margin.add_child(center)

	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.alignment = BoxContainer.ALIGNMENT_BEGIN
	row.add_theme_constant_override("separation", 4)
	row.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	center.add_child(row)

	var output_label := Label.new()
	output_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	output_label.text = str(recipe.get("output_display_name", _recipe_output_name(recipe)))
	output_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	output_label.modulate = Color(1.0, 0.82, 0.4, 1.0)
	row.add_child(output_label)

	var equals_label := Label.new()
	equals_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	equals_label.text = "="
	equals_label.modulate = Color(0.82, 0.84, 0.9, 1.0)
	row.add_child(equals_label)

	var inputs: Array = recipe.get("inputs", [])
	for index in range(inputs.size()):
		var input: Dictionary = inputs[index]
		var unit_id: String = str(input.get("unit_id", ""))
		var required_count: int = int(input.get("count", 0))
		var owned_count: int = int(owned_counts.get(unit_id, 0))
		var input_button := LinkButton.new()
		input_button.focus_mode = Control.FOCUS_NONE
		input_button.text = "%s x%d" % [GameState.get_unit_display_name(unit_id), required_count]
		input_button.underline = LinkButton.UNDERLINE_MODE_NEVER
		input_button.modulate = Color(1.0, 1.0, 1.0, 1.0) if owned_count >= required_count else Color(0.58, 0.6, 0.64, 1.0)
		input_button.pressed.connect(_on_recipe_browser_input_pressed.bind(unit_id))
		row.add_child(input_button)

		if index < inputs.size() - 1:
			var plus_label := Label.new()
			plus_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			plus_label.text = "+"
			plus_label.modulate = Color(0.82, 0.84, 0.9, 1.0)
			row.add_child(plus_label)


func _build_modal_overlays() -> void:
	var shop_nodes: Dictionary = _create_modal_overlay("상점", Vector2(980, 680))
	_shop_overlay = shop_nodes.get("overlay")
	_shop_overlay_panel = shop_nodes.get("panel")
	_shop_overlay_title = shop_nodes.get("title")
	var shop_body: VBoxContainer = shop_nodes.get("body")
	_build_shop_overlay_content(shop_body)

	var mission_nodes: Dictionary = _create_modal_overlay("임무", Vector2(760, 620))
	_mission_overlay = mission_nodes.get("overlay")
	_mission_overlay_panel = mission_nodes.get("panel")
	_mission_overlay_title = mission_nodes.get("title")
	var mission_body: VBoxContainer = mission_nodes.get("body")
	_build_mission_overlay_content(mission_body)

	var forge_nodes: Dictionary = _create_modal_overlay("대장간", Vector2(900, 700))
	_forge_overlay = forge_nodes.get("overlay")
	_forge_overlay_panel = forge_nodes.get("panel")
	_forge_overlay_title = forge_nodes.get("title")
	var forge_body: VBoxContainer = forge_nodes.get("body")
	_build_forge_overlay_content(forge_body)


func _create_modal_overlay(title_text: String, panel_size: Vector2) -> Dictionary:
	var overlay := Control.new()
	overlay.visible = false
	overlay.anchors_preset = Control.PRESET_FULL_RECT
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.grow_horizontal = Control.GROW_DIRECTION_BOTH
	overlay.grow_vertical = Control.GROW_DIRECTION_BOTH
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	var dim := ColorRect.new()
	dim.anchors_preset = Control.PRESET_FULL_RECT
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	dim.grow_horizontal = Control.GROW_DIRECTION_BOTH
	dim.grow_vertical = Control.GROW_DIRECTION_BOTH
	dim.color = Color(0, 0, 0, 0.78)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(dim)

	var center := CenterContainer.new()
	center.anchors_preset = Control.PRESET_FULL_RECT
	center.anchor_right = 1.0
	center.anchor_bottom = 1.0
	center.grow_horizontal = Control.GROW_DIRECTION_BOTH
	center.grow_vertical = Control.GROW_DIRECTION_BOTH
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = panel_size
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)

	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 10)
	margin.add_child(body)

	var header := HBoxContainer.new()
	body.add_child(header)

	var title_label := Label.new()
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.text = title_text
	header.add_child(title_label)

	var close_button := Button.new()
	close_button.custom_minimum_size = Vector2(90, 36)
	close_button.text = "닫기"
	close_button.pressed.connect(_close_modal_overlay.bind(overlay))
	header.add_child(close_button)

	overlay.gui_input.connect(_on_modal_overlay_input.bind(overlay, panel))
	dim.gui_input.connect(_on_modal_overlay_dim_input.bind(overlay))
	add_child(overlay)
	return {
		"overlay": overlay,
		"panel": panel,
		"title": title_label,
		"body": body,
	}


func _build_shop_overlay_content(body: VBoxContainer) -> void:
	var intro := Label.new()
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.text = "유닛 뽑기와 선택 뽑기를 사용할 수 있습니다."
	body.add_child(intro)

	var random_row := HBoxContainer.new()
	random_row.add_theme_constant_override("separation", 8)
	body.add_child(random_row)

	_shop_random_button = Button.new()
	_shop_random_button.custom_minimum_size = Vector2(180, 40)
	_shop_random_button.pressed.connect(_on_shop_random_draw_pressed)
	random_row.add_child(_shop_random_button)

	_shop_random_info_label = Label.new()
	_shop_random_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_shop_random_info_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	random_row.add_child(_shop_random_info_label)

	var rarity_row := HBoxContainer.new()
	rarity_row.alignment = BoxContainer.ALIGNMENT_CENTER
	rarity_row.add_theme_constant_override("separation", 8)
	body.add_child(rarity_row)
	for rarity: String in ["common", "rare", "unique"]:
		var rarity_button := Button.new()
		rarity_button.custom_minimum_size = Vector2(100, 34)
		rarity_button.text = _rarity_label(rarity)
		rarity_button.pressed.connect(_on_shop_rarity_pressed.bind(rarity))
		rarity_row.add_child(rarity_button)
		_shop_rarity_buttons[rarity] = rarity_button

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(scroll)

	_shop_unit_grid = GridContainer.new()
	_shop_unit_grid.columns = 4
	_shop_unit_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_shop_unit_grid)

	_shop_status_label = Label.new()
	_shop_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(_shop_status_label)


func _build_mission_overlay_content(body: VBoxContainer) -> void:
	_mission_overlay_hint = Label.new()
	_mission_overlay_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(_mission_overlay_hint)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(scroll)

	_mission_overlay_buttons = VBoxContainer.new()
	_mission_overlay_buttons.add_theme_constant_override("separation", 8)
	scroll.add_child(_mission_overlay_buttons)


func _build_forge_overlay_content(body: VBoxContainer) -> void:
	_forge_overlay_hint = Label.new()
	_forge_overlay_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_forge_overlay_hint.text = "강화 단계가 높아질수록 골드 소모가 점점 늘어납니다."
	body.add_child(_forge_overlay_hint)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(scroll)

	_forge_overlay_list = VBoxContainer.new()
	_forge_overlay_list.add_theme_constant_override("separation", 8)
	scroll.add_child(_forge_overlay_list)


func _rarity_label(rarity: String) -> String:
	match rarity:
		"common":
			return "커먼"
		"rare":
			return "커먼"
		"unique":
			return "유니크"
		"legendary":
			return "레전더리"
		"transcendent":
			return "초월자"
		"immortal":
			return "불멸자"
		"god":
			return "?"
		"liberator":
			return "해방자"
		_:
			return rarity


func _on_shop_overlay_open_pressed() -> void:
	refresh()
	_refresh_shop_overlay()
	_shop_overlay.visible = true


func _on_mission_overlay_open_pressed() -> void:
	refresh()
	_refresh_mission_overlay()
	_mission_overlay.visible = true


func _on_forge_overlay_open_pressed() -> void:
	refresh()
	_refresh_forge_overlay()
	_forge_overlay.visible = true


func _refresh_shop_overlay() -> void:
	if _shop_overlay == null:
		return
	_shop_overlay_title.text = "상점"
	_shop_random_button.text = "유닛 뽑기 (%dG)" % GameState.get_shop_random_draw_cost()
	_shop_random_info_label.text = "커먼 또는 레어 유닛을 확률적으로 뽑습니다."
	_shop_status_label.text = "최근 결과: %s" % (str(GameState.recent_draw_units.back().get("display_name", "없음")) if not GameState.recent_draw_units.is_empty() else "없음")
	for rarity: String in _shop_rarity_buttons.keys():
		var rarity_button: Button = _shop_rarity_buttons[rarity]
		rarity_button.disabled = rarity == _shop_selected_rarity

	for child in _shop_unit_grid.get_children():
		child.queue_free()

	for entry: Dictionary in GameState.get_shop_units_by_rarity(_shop_selected_rarity):
		var card := Button.new()
		card.focus_mode = Control.FOCUS_NONE
		card.custom_minimum_size = Vector2(140, 140)
		card.tooltip_text = str(entry.get("display_name", ""))
		card.pressed.connect(_on_shop_targeted_draw_pressed.bind(str(entry.get("definition_id", ""))))
		var margin := MarginContainer.new()
		margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		margin.anchors_preset = Control.PRESET_FULL_RECT
		margin.offset_left = 6
		margin.offset_top = 6
		margin.offset_right = -6
		margin.offset_bottom = -6
		card.add_child(margin)
		var content := VBoxContainer.new()
		content.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.alignment = BoxContainer.ALIGNMENT_CENTER
		content.add_theme_constant_override("separation", 1)
		margin.add_child(content)
		var icon := TextureRect.new()
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.custom_minimum_size = Vector2(52, 52)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = ActorViewFactory.create_unit_icon_texture(entry.get("definition", {}))
		content.add_child(icon)
		var name_label := Label.new()
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		name_label.add_theme_font_size_override("font_size", 12)
		name_label.text = str(entry.get("display_name", ""))
		content.add_child(name_label)
		var cost_label := Label.new()
		cost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cost_label.text = "%dG" % GameState.get_shop_targeted_draw_cost(_shop_selected_rarity)
		content.add_child(cost_label)
		_shop_unit_grid.add_child(card)


func _refresh_mission_overlay() -> void:
	if _mission_overlay == null:
		return
	_mission_overlay_title.text = "임무"
	_mission_overlay_hint.text = "해금된 Mission Boss를 여러 개 동시에 소환할 수 있습니다."
	for child in _mission_overlay_buttons.get_children():
		child.queue_free()
	for mission_state: Dictionary in GameState.get_mission_boss_states():
		var mission_button := Button.new()
		mission_button.focus_mode = Control.FOCUS_NONE
		mission_button.custom_minimum_size = Vector2(0, 42)
		var unlocked: bool = bool(mission_state.get("unlocked", false))
		var cooldown_remaining: float = float(mission_state.get("cooldown_remaining", 0.0))
		var mission_id: String = str(mission_state.get("id", ""))
		if not unlocked:
			mission_button.text = "%s (잠금)" % mission_id
			mission_button.disabled = true
		elif cooldown_remaining > 0.0:
			mission_button.text = "%s (%ds)" % [mission_id, int(ceil(cooldown_remaining))]
			mission_button.disabled = true
		else:
			mission_button.text = "%s 소환" % mission_id
			mission_button.pressed.connect(_on_mission_boss_pressed.bind(mission_id))
		_mission_overlay_buttons.add_child(mission_button)


func _refresh_forge_overlay() -> void:
	if _forge_overlay == null:
		return
	_forge_overlay_title.text = "대장간"
	for child in _forge_overlay_list.get_children():
		child.queue_free()
	for entry: Dictionary in GameState.get_forge_upgrade_entries():
		var upgrade_button := Button.new()
		upgrade_button.focus_mode = Control.FOCUS_NONE
		upgrade_button.custom_minimum_size = Vector2(0, 42)
		upgrade_button.text = "%s  Lv.%d  /  %dG" % [str(entry.get("label", "")), int(entry.get("level", 0)), int(entry.get("cost", 0))]
		upgrade_button.pressed.connect(_on_forge_upgrade_pressed.bind(str(entry.get("id", ""))))
		_forge_overlay_list.add_child(upgrade_button)


func _on_shop_random_draw_pressed() -> void:
	if GameState.purchase_random_draw():
		_refresh_shop_overlay()


func _on_shop_rarity_pressed(rarity: String) -> void:
	_shop_selected_rarity = rarity
	_refresh_shop_overlay()


func _on_shop_targeted_draw_pressed(unit_id: String) -> void:
	if GameState.purchase_targeted_draw(unit_id):
		_refresh_shop_overlay()


func _on_forge_upgrade_pressed(upgrade_id: String) -> void:
	if GameState.purchase_forge_upgrade(upgrade_id):
		_refresh_forge_overlay()


func _close_modal_overlay(overlay: Control) -> void:
	overlay.visible = false


func _on_modal_overlay_input(event: InputEvent, overlay: Control, panel: Control) -> void:
	if not overlay.visible:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not panel.get_global_rect().has_point(get_viewport().get_mouse_position()):
			overlay.visible = false


func _on_modal_overlay_dim_input(event: InputEvent, overlay: Control) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		overlay.visible = false
		get_viewport().set_input_as_handled()


func _show_unit_recipe_tooltip(recipe: Dictionary, anchor: Control) -> void:
	for child in _unit_recipe_tooltip_icons.get_children():
		child.queue_free()
	for child in _unit_recipe_tooltip_formula_flow.get_children():
		child.queue_free()

	var owned_counts: Dictionary = GameState.get_owned_unit_counts()
	var output_name: String = GameState.get_unit_display_name(str(recipe.get("output_unit_id", "")))
	_unit_recipe_tooltip_label.text = output_name
	_add_tooltip_formula_token(_unit_recipe_tooltip_formula_flow, "%s =" % output_name, Color(1.0, 0.82, 0.4, 1.0))

	var inputs: Array = recipe.get("inputs", [])
	for index in range(inputs.size()):
		var input: Dictionary = inputs[index]
		var unit_id: String = str(input.get("unit_id", ""))
		var count: int = int(input.get("count", 0))
		var owned_count: int = int(owned_counts.get(unit_id, 0))
		var token_color: Color = Color(1.0, 1.0, 1.0, 1.0) if owned_count >= count else Color(0.58, 0.6, 0.64, 1.0)
		_add_tooltip_formula_token(_unit_recipe_tooltip_formula_flow, "%s x%d" % [GameState.get_unit_display_name(unit_id), count], token_color)

		var icon := TextureRect.new()
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.custom_minimum_size = Vector2(32, 32)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = ActorViewFactory.create_unit_icon_texture(GameState.get_unit_definition(unit_id))
		icon.modulate = token_color
		_unit_recipe_tooltip_icons.add_child(icon)

		if index < inputs.size() - 1:
			_add_tooltip_formula_token(_unit_recipe_tooltip_formula_flow, "+", Color(0.82, 0.84, 0.9, 1.0))
	var anchor_rect: Rect2 = anchor.get_global_rect()
	var viewport_rect: Rect2 = get_viewport().get_visible_rect()
	var tooltip_width: float = maxf(_unit_recipe_tooltip.size.x, 300.0)
	var tooltip_height: float = maxf(_unit_recipe_tooltip.size.y, 120.0)
	var tooltip_position := Vector2(
		anchor_rect.position.x + anchor_rect.size.x * 0.5 - tooltip_width * 0.5,
		anchor_rect.position.y - tooltip_height - 10.0
	)
	if tooltip_position.y < viewport_rect.position.y + 12.0:
		tooltip_position.y = anchor_rect.end.y + 10.0
	if tooltip_position.x + tooltip_width > viewport_rect.end.x - 12.0:
		tooltip_position.x = viewport_rect.end.x - tooltip_width - 12.0
	if tooltip_position.x < viewport_rect.position.x + 12.0:
		tooltip_position.x = viewport_rect.position.x + 12.0
	if tooltip_position.y + tooltip_height > viewport_rect.end.y - 12.0:
		tooltip_position.y = viewport_rect.end.y - tooltip_height - 12.0
	_unit_recipe_tooltip.global_position = tooltip_position
	_unit_recipe_tooltip.visible = true


func _hide_unit_recipe_tooltip() -> void:
	_unit_recipe_tooltip.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if _settings_overlay != null and _settings_overlay.visible:
			_close_settings_overlay()
		elif _pause_overlay != null and _pause_overlay.visible:
			_close_pause_overlay()
		else:
			_open_pause_overlay()
		get_viewport().set_input_as_handled()
		return
	if not _recipe_overlay.visible:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not _recipe_overlay_panel.get_global_rect().has_point(get_viewport().get_mouse_position()):
			_recipe_overlay.visible = false
