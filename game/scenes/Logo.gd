extends Control

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _on_timer_timeout():
	$SceneFader.transition_to()
