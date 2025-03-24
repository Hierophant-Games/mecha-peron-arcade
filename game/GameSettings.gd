extends Node


@export var music_volume := 0.75: set = set_music_volume
@export var sound_volume := 0.9: set = set_sound_volume
@export var voice_volume := 0.9: set = set_voice_volume
@export var cursor_rotation := 0: set = set_cursor_rotation
@export var h_stretch := 0: set = set_h_stretch
@export var v_stretch := 0: set = set_v_stretch

const FILENAME := "user://settings.cfg"

var loading_config := false

func _ready():
	load_config.call_deferred()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("exit_game"):
		get_tree().quit()
	elif Input.is_action_just_pressed("open_settings"):
		(get_tree().current_scene as MainViewport).change_scene("res://game/scenes/Options.tscn")
	elif Input.is_action_just_pressed("cursor_rotation"):
		cursor_rotation = (cursor_rotation + 1) % 4
	elif Input.is_action_just_pressed("h_stretch_down"):
		h_stretch = h_stretch - 1
	elif Input.is_action_just_pressed("h_stretch_up"):
		h_stretch = h_stretch + 1
	elif Input.is_action_just_pressed("v_stretch_down"):
		v_stretch = v_stretch - 1
	elif Input.is_action_just_pressed("v_stretch_up"):
		v_stretch = v_stretch + 1

func set_music_volume(value: float):
	music_volume = value
	var music_bus_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(value))
	save_config()

func set_sound_volume(value: float):
	sound_volume = value
	var sfx_bus_index = AudioServer.get_bus_index("Sfx")
	AudioServer.set_bus_volume_db(sfx_bus_index, linear_to_db(value))
	save_config()

func set_voice_volume(value: float):
	voice_volume = value
	var voice_bus_index = AudioServer.get_bus_index("Voice")
	AudioServer.set_bus_volume_db(voice_bus_index, linear_to_db(value))
	save_config()

func set_cursor_rotation(value: int):
	cursor_rotation = value

	InputMap.load_from_project_settings() # clear any previous rotation
	var cursor_up_events := InputMap.action_get_events("cursor_up")
	var cursor_right_events := InputMap.action_get_events("cursor_right")
	var cursor_down_events := InputMap.action_get_events("cursor_down")
	var cursor_left_events := InputMap.action_get_events("cursor_left")
	var ui_up_events := InputMap.action_get_events("ui_up")
	var ui_right_events := InputMap.action_get_events("ui_right")
	var ui_down_events := InputMap.action_get_events("ui_down")
	var ui_left_events := InputMap.action_get_events("ui_left")

	match value:
		0:
			pass
		1:
			replace_events("cursor_up", cursor_right_events)
			replace_events("cursor_right", cursor_down_events)
			replace_events("cursor_down", cursor_left_events)
			replace_events("cursor_left", cursor_up_events)
			replace_events("ui_up", ui_right_events)
			replace_events("ui_right", ui_down_events)
			replace_events("ui_down", ui_left_events)
			replace_events("ui_left", ui_up_events)
		2:
			replace_events("cursor_up", cursor_down_events)
			replace_events("cursor_right", cursor_left_events)
			replace_events("cursor_down", cursor_up_events)
			replace_events("cursor_left", cursor_right_events)
			replace_events("ui_up", ui_down_events)
			replace_events("ui_right", ui_left_events)
			replace_events("ui_down", ui_up_events)
			replace_events("ui_left", ui_right_events)
		3:
			replace_events("cursor_up", cursor_left_events)
			replace_events("cursor_right", cursor_up_events)
			replace_events("cursor_down", cursor_right_events)
			replace_events("cursor_left", cursor_down_events)
			replace_events("ui_up", ui_left_events)
			replace_events("ui_right", ui_up_events)
			replace_events("ui_down", ui_right_events)
			replace_events("ui_left", ui_down_events)

	save_config()

func set_h_stretch(value: int) -> void:
	h_stretch = value
	set_screen_stretch()
	save_config()

func set_v_stretch(value: int) -> void:
	v_stretch = value
	set_screen_stretch()
	save_config()

func set_screen_stretch() -> void:
	(get_tree().current_scene as MainViewport).stretch(h_stretch, v_stretch)

func replace_events(action: StringName, events: Array[InputEvent]) -> void:
	InputMap.action_erase_events(action)
	for event in events:
		InputMap.action_add_event(action, event)

func load_config():
	var config := ConfigFile.new()
	if config.load(FILENAME) != OK:
		return
	loading_config = true
	music_volume = config.get_value("audio", "music_volume", music_volume)
	sound_volume = config.get_value("audio", "sound_volume", sound_volume)
	sound_volume = config.get_value("audio", "voice_volume", voice_volume)
	cursor_rotation = config.get_value("input", "cursor_rotation", cursor_rotation)
	h_stretch = config.get_value("screen", "h_stretch", h_stretch)
	v_stretch = config.get_value("screen", "v_stretch", v_stretch)
	loading_config = false

func save_config():
	if loading_config:
		return
	print("Saving config")
	var config := ConfigFile.new()
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sound_volume", sound_volume)
	config.set_value("audio", "voice_volume", voice_volume)
	config.set_value("input", "cursor_rotation", cursor_rotation)
	config.set_value("screen", "h_stretch", h_stretch)
	config.set_value("screen", "v_stretch", v_stretch)
	config.save(FILENAME)
