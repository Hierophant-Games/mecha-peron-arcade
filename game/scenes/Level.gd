class_name Level
extends Node2D

const AirplaneScene = preload("res://game/enemies/Airplane.tscn")
const EnemyBuildingScene = preload("res://game/enemies/EnemyBuilding.tscn")
const FloatingTextScene = preload("res://game/tutorial/FloatingText.tscn")

enum { PRE_INTRO, INTRO, POST_INTRO }
var intro_state := PRE_INTRO

@export_file("*.tscn") var enter_your_name_scene: String

@onready var main_layer := $ParallaxBackground/MainLayer
@onready var front_layer := $ParallaxBackground/FrontLayer as Parallax2D
@onready var foreground := $ParallaxBackground/FrontLayer/Foreground as Foreground
@onready var peron := $ParallaxBackground/MainLayer/Peron as Peron
@onready var camera := $ParallaxBackground/MainLayer/Peron/Camera2D as Camera2D
@onready var hud := $GUILayer/HUD as HUD
@onready var game_over := $GUILayer/GameOver as GameOver
@onready var scene_fader := $GUILayer/SceneFader as SceneFader

var _is_first_building := true
var _is_first_cannon := true

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	GlobalAudio.stop_music()
	ScoreTracker.reset()
	hud.hide()
	game_over.hide()

func _process(_delta: float):
	update_intro()
	update_foreground()

	if intro_state != POST_INTRO:
		return

	var distance := peron.position.x
	ScoreTracker.set_distance(distance)
	input()
	
	if !game_over.visible and peron.dying:
		game_over.show()

func update_intro():
	match intro_state:
		PRE_INTRO:
			camera.global_position.x = global_position.x
			if Input.is_action_just_pressed("ui_accept"):
				Engine.time_scale = 4;
			if peron.position.x > 0:
				intro_state = INTRO
				Engine.time_scale = 1
				peron.blocked = true
				peron.idle()
		INTRO:
			peron.blocked = false
			peron.walk()
			hud.show()
			GlobalAudio.play_ingame_music()
			intro_state = POST_INTRO

func input():
	if peron.dying:
		return

	# CHEATS
	if OS.has_feature('debug'):
		if Input.is_key_pressed(KEY_G):
			peron.health = 0

	var shoot_laser_pressed := Input.is_action_pressed("shoot_laser")

	if peron.shooting_laser:
		if shoot_laser_pressed:
			peron.aim_laser()
		else:
			peron.laser_reverse()

	if peron.is_attacking():
		return
	
	if Input.is_action_just_pressed("attack_fist"):
		peron.attack_fist()
		return
	elif Input.is_action_just_pressed("attack_arm"):
		peron.attack_arm()
		return
	if shoot_laser_pressed:
		laser()

func laser():
	peron.laser()
	peron.aim_laser()

func update_foreground():
	foreground.update_buildings(int(get_front_layer_screen_right()))

func _on_AIDirector_enemy_needed(enemy_type: String, x: float):
	match enemy_type:
		"plane":
			spawn_plane(x)
		"building":
			spawn_building(x)
		"cannon":
			spawn_cannon()

func spawn_plane(x: float) -> void:
	var plane := AirplaneScene.instantiate() as Airplane
	plane.position.x = get_viewport_rect().size.x + x
	main_layer.add_child(plane)

func spawn_building(x: float) -> void:
	var enemy_building := EnemyBuildingScene.instantiate() as EnemyBuilding
	enemy_building.position.y = get_viewport_rect().size.y
	enemy_building.position.x = get_viewport_rect().size.x + x
	main_layer.add_child(enemy_building)
	if _is_first_building:
		_is_first_building = false
		front_layer.add_child(spawn_floating_text(
			tr("ROCKET_PUNCH_TUTORIAL_TEXT"),
			Vector2((enemy_building.position.x - 100) * front_layer.scroll_scale.x, 30)
		))

func spawn_cannon() -> void:
	foreground.prepare_cannon()
	if _is_first_cannon:
		_is_first_cannon = false
		front_layer.add_child(spawn_floating_text(
			tr("HAMMER_FIST_TUTORIAL_TEXT"),
			Vector2(get_front_layer_screen_right() - 20, 60)
		))

func spawn_floating_text(text: String, pos: Vector2) -> Label:
	var label := FloatingTextScene.instantiate() as Label
	label.text = text
	label.position = pos
	return label

func get_front_layer_screen_right() -> float:
	return (camera.global_position.x + get_viewport_rect().size.x) * front_layer.scroll_scale.x

func _on_game_over_main_menu_pressed() -> void:
	scene_fader.transition_to(enter_your_name_scene)
