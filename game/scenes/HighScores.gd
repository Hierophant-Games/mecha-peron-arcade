extends Control

@onready var HiscoreContainer := $MarginContainer/VBoxContainer/MarginContainer/HiscoreContainer as Container

var placeholders: Array[ScoreTracker.ScoreEntry] = [
	ScoreTracker.ScoreEntry.new("EVA", 1234),
	ScoreTracker.ScoreEntry.new("JDP", 1234),
	ScoreTracker.ScoreEntry.new("CFK", 1234),
	ScoreTracker.ScoreEntry.new("NCK", 1234),
	ScoreTracker.ScoreEntry.new("CCK", 1234),
	ScoreTracker.ScoreEntry.new("CHE", 1234),
	ScoreTracker.ScoreEntry.new("FID", 1234),
	ScoreTracker.ScoreEntry.new("JWC", 1234),
	ScoreTracker.ScoreEntry.new("JPN", 1234),
	ScoreTracker.ScoreEntry.new("NIK", 1),
]

func _ready() -> void:
	#ScoreTracker.set_distance(500)
	#ScoreTracker.store_score("SMV")
	
	var scores := ScoreTracker.get_scores()
	#scores.append_array(placeholders)
	scores.sort_custom(func (a, b): return a.score > b.score)
	
	var in_top_ten := false
	var current_score := ScoreTracker.get_current_score()
	
	for i in range(mini(10, scores.size())):
		var score = scores[i]
		var score_node := create_score_node(i, score)
		
		if !in_top_ten && score.equals(current_score):
			score_node.modulate = Color.YELLOW
			in_top_ten = true
		
		HiscoreContainer.add_child(score_node)
	
	if !in_top_ten:
		for i in range(10, scores.size()):
			if scores[i].equals(current_score):
				if i > 10:
					var label := Label.new()
					label.text = "--------------------"
					label.add_theme_font_size_override("font_size", 8)
					HiscoreContainer.add_child(label)
				var score_node := create_score_node(i, ScoreTracker.get_current_score())
				score_node.modulate = Color.YELLOW
				HiscoreContainer.add_child(score_node)
				break

func create_score_node(index: int, score: ScoreTracker.ScoreEntry) -> Node:
	var initials_label := Label.new()
	initials_label.text = "%d. %s" % [index+1, score.initials]
	initials_label.add_theme_font_size_override("font_size", 8)
	
	var score_label := Label.new()
	score_label.text = score.get_score_text()
	score_label.add_theme_font_size_override("font_size", 8)
	
	var container := HBoxContainer.new()
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	container.add_child(initials_label)
	container.add_spacer(false)
	container.add_child(score_label)
	
	return container

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		$SceneFader.transition_to()
