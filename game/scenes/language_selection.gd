class_name LanguageSelection extends Control

func _on_english_pressed() -> void:
	TranslationServer.set_locale("en")
	$SceneFader.transition_to()


func _on_spanish_pressed() -> void:
	TranslationServer.set_locale("es")
	$SceneFader.transition_to()
