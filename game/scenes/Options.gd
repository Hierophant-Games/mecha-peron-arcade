extends Control

@export_file("*.tscn") var back_scene: String

@onready var music_slider := $MarginContainer/VBoxContainer/MusicSettings/Slider as HSlider
@onready var sound_slider := $MarginContainer/VBoxContainer/SoundSettings/Slider as HSlider
@onready var voice_slider := $MarginContainer/VBoxContainer/VoiceSettings/Slider as HSlider
@onready var h_stretch_slider := $MarginContainer/VBoxContainer/HBoxContainer2/HorizontalStretch/Slider as HSlider
@onready var v_stretch_slider := $MarginContainer/VBoxContainer/HBoxContainer2/VerticalStretch/Slider as HSlider
@onready var sound_sample := $SoundSample as AudioStreamPlayer
@onready var voice_sample := $VoiceSample as AudioStreamPlayer

# Prevent playing samples when setting the slider values initially
var should_play_samples := false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	GlobalAudio.play_menu_music()
	music_slider.value = GameSettings.music_volume
	sound_slider.value = GameSettings.sound_volume
	voice_slider.value = GameSettings.voice_volume
	h_stretch_slider.value = GameSettings.h_stretch
	v_stretch_slider.value = GameSettings.v_stretch
	should_play_samples = true

func _on_back_button_pressed():
	$SceneFader.transition_to(back_scene, false)

func _on_music_slider_value_changed(value: float):
	GameSettings.music_volume = value

func _on_sound_slider_value_changed(value: float):
	GameSettings.sound_volume = value
	if should_play_samples:
		sound_sample.play()

func _on_voice_slider_value_changed(value: float):
	GameSettings.voice_volume = value
	if should_play_samples:
		voice_sample.play()

func _on_spanish_pressed() -> void:
	TranslationServer.set_locale("es")

func _on_english_pressed() -> void:
	TranslationServer.set_locale("en")

func _on_cursor_rotation_pressed(value: int) -> void:
	GameSettings.cursor_rotation = value

func _on_h_stretch_slider_value_changed(value: float):
	GameSettings.h_stretch = int(value)

func _on_v_stretch_slider_value_changed(value: float):
	GameSettings.v_stretch = int(value)
