extends Control

const ALPHABET := "ABCDEFGHIJKLMNÑOPQRSTUVWXYZÁÉÍÓÚ0123456789.,~!@#$%^&*()[]/\\-_+?"

var _current_initial := 0
var _selected_character := 0
var _keyboard_ready := false
var _chars_per_line: Array[int] = []

@onready var initials := [
	$MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/Initial1,
	$MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/Initial2,
	$MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/Initial3,
] as Array[Label]

@onready var keyboard_container := $MarginContainer/VBoxContainer/HFlowContainer as HFlowContainer
@onready var top_container := $MarginContainer

func _ready() -> void:
	# Hide the container with alpha instead of using visibility because we need
	# to compute the layout while we add the labels, and if we hide() the node,
	# then the children will optimize the whole thing out
	top_container.modulate = Color.TRANSPARENT
	await populate_keyboard()
	top_container.modulate = Color.WHITE

func _process(_delta: float) -> void:
	if !_keyboard_ready:
		return
	
	for i in range(initials.size()):
		initials[i].modulate = Color.YELLOW if i == _current_initial else Color.WHITE
	for i in range(keyboard_container.get_child_count()):
		keyboard_container.get_children()[i].modulate = Color.YELLOW if i == _selected_character else Color.WHITE
	
	if Input.is_action_just_pressed("cursor_right"):
		_selected_character += 1
	if Input.is_action_just_pressed("cursor_left"):
		_selected_character -= 1
	if Input.is_action_just_pressed("cursor_up"):
		jump_line(-1)
	if Input.is_action_just_pressed("cursor_down"):
		jump_line(1)
	if Input.is_action_just_pressed("ui_accept"):
		next_initial()
	if Input.is_action_just_pressed("ui_cancel"):
		prev_initial()
	
	_selected_character = clampi(_selected_character, 0, ALPHABET.length() - 1)
	
	initials[_current_initial].text = ALPHABET[_selected_character]

func jump_line(direction: int) -> void:
	var current_line := 0
	var accum_chars := 0
	for chars in _chars_per_line:
		accum_chars += chars
		if _selected_character > accum_chars - 1:
			current_line += 1
	
	# Early return invalid cases
	if current_line == 0 && direction < 0:
		return
	if current_line == _chars_per_line.size() - 1 && direction > 0:
		return
	
	accum_chars = 0
	for i in range(current_line):
		accum_chars += _chars_per_line[i]
		
	# accum_chars now holds the value of amount of chars until the start of the
	# current line
	
	# Compute the position in the line of the selected character to get the
	# ratio in the line [0, 1]
	var position_in_line := _selected_character - accum_chars
	var current_ratio := float(position_in_line) / (_chars_per_line[current_line] - 1)
	# And then use the ratio to calculate the position in the next line
	var next_line := current_line + direction
	var new_position := roundi(current_ratio * (_chars_per_line[next_line] - 1))
	
	if direction > 0:
		_selected_character = accum_chars + _chars_per_line[current_line] + new_position
	else:
		_selected_character = accum_chars - _chars_per_line[next_line] + new_position

func populate_keyboard() -> void:
	var current_lines := 1
	var current_line_chars := 0
	
	for character in ALPHABET:
		var label := Label.new()
		label.text = character
		keyboard_container.add_child(label)
		current_line_chars += 1
		# we need to wait for a render to be able to know how many chars have
		# been added to each line
		await get_tree().create_timer(0).timeout
		if keyboard_container.get_line_count() > current_lines:
			_chars_per_line.push_back(current_line_chars - 1)
			current_line_chars = 1
			current_lines += 1
	
	_chars_per_line.push_back(current_line_chars)
	_keyboard_ready = true
	
func next_initial() -> void:
	if _current_initial == initials.size() - 1:
		$SceneFader.transition_to()
		var initials_text = initials \
			.map(func (label: Label): return label.text) \
			.reduce(func(accum: String, text: String): return accum + text, "")
		ScoreTracker.store_score(initials_text)
		return
		
	_current_initial += 1

func prev_initial() -> void:
	_current_initial = maxi(0, _current_initial - 1)
