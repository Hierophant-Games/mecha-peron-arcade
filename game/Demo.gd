extends Node

const MAIN_MENU_FILEPATH := "res://game/scenes/MainMenu.tscn"
const MAIN_MENU_IDLE_TIME := 2.0

const DEMO_SCENES := [
	"res://game/scenes/Credits.tscn",
	"res://game/scenes/HighScores.tscn",
	"res://game/scenes/Help.tscn",
	"res://game/scenes/Logo.tscn",
]

const DEMO_SCENE_TIMES := [
	28.0,
	10.0,
	15.0,
	2.0,
]

var timer := Timer.new()
var current_demo_scene := -1

func _ready() -> void:
	timer.one_shot = true;
	timer.timeout.connect(on_timeout)
	add_child(timer)

	# Listen to the tree changing to know where to start the timer for the demo
	get_tree().tree_changed.connect(on_tree_changed)

func _process(_delta: float) -> void:
	if !Input.is_anything_pressed():
		return

	# If input received while in demo, stop demo
	if current_demo_scene >= 0:
		stop_demo()
	# else, if timer is running, reset the timer
	elif !timer.is_stopped():
		timer.stop()
		timer.start()

func on_timeout() -> void:
	if current_demo_scene + 1 < DEMO_SCENES.size():
		current_demo_scene += 1
		get_tree().change_scene_to_file(DEMO_SCENES[current_demo_scene])
		timer.start(DEMO_SCENE_TIMES[current_demo_scene])
	else:
		stop_demo()

func on_tree_changed() -> void:
	if current_demo_scene >= 0:
		return
	if get_tree() && get_tree().current_scene && get_tree().current_scene.scene_file_path == MAIN_MENU_FILEPATH:
		if timer.is_stopped():
			timer.start(MAIN_MENU_IDLE_TIME)
	elif !timer.is_stopped():
		timer.stop()

func stop_demo() -> void:
	current_demo_scene = -1
	get_tree().change_scene_to_file(MAIN_MENU_FILEPATH)
