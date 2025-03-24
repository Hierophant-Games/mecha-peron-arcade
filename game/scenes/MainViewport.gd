class_name MainViewport
extends Control

@onready var sub_viewport := $MarginContainer/SubViewportContainer/SubViewport as SubViewport
@onready var container := $MarginContainer as MarginContainer

func get_current_scene() -> Node:
	return sub_viewport.get_child(0)

func get_current_scene_path() -> String:
	return get_current_scene().scene_file_path

func change_scene(path: String) -> void:
	# Note: `queue_free` is not the same, according to the documentation it is
	# executed after all deferred calls, and in this case I want to defer the
	# free call and then call the add_child, to mimic the SceneTree behavior
	get_current_scene().free.call_deferred()
	var scene := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REUSE) as PackedScene
	sub_viewport.add_child.call_deferred(scene.instantiate())

func stretch(x: int, y: int) -> void:
	container.add_theme_constant_override("margin_left", -x)
	container.add_theme_constant_override("margin_right", -x)
	container.add_theme_constant_override("margin_top", -y)
	container.add_theme_constant_override("margin_bottom", -y)
