extends Node

enum EnemyType {
	PLANE,
	BUILDING,
	SOLDIER,
	CANNON
}

const ENEMY_NAMES := ["Plane", "Building", "Soldier", "Cannon"]
const SCORE_VALUES := [10, 20, 1, 20]
const DISTANCE_SCALE_FACTOR := 300.0

const SCORES_FILENAME := "user://scores.dat"

var _score := 0
var _killed_count := [0, 0, 0, 0]
var _distance_traveled := 0.0
var _interpolated_score := 0.0

var _hiscore: ScoreEntry = null
var _current_initials := ""

func reset():
	_killed_count = [0, 0, 0, 0]
	_score = 0
	_distance_traveled = 0.0
	_current_initials = ""
	_hiscore = get_hiscore()
	if OS.has_feature('debug'):
		print("Score was reset!")

func track_killed(type: EnemyType):
	_killed_count[type] += 1;
	_score += SCORE_VALUES[type];
	if OS.has_feature('debug'):
		print("Score: ", _score, " total ", ENEMY_NAMES[type], "(s) killed: ", _killed_count[type])

func set_distance(value: float):
	_distance_traveled = value / DISTANCE_SCALE_FACTOR

func get_distance_text() -> String:
	return tr("SCORE_DISTANCE_TEXT").format({"distance_score": str(_distance_traveled).pad_decimals(2)})

func get_score_text() -> String:
	return tr("SCORE_DESTRUCTION_TEXT").format({"destruction_score": _score})

func get_interpolated_score_text(delta: float) -> String:
	_interpolated_score = minf(_score, _interpolated_score + delta * 10)
	return tr("HUD_DESTRUCTION_TEXT").format({"interpolated_score": int(_interpolated_score)})

func get_hiscore_text() -> String:
	if _hiscore:
		return tr("HISCORE_TEXT").format({"hiscore": _hiscore.get_score_text() })
	else:
		return ""

class ScoreEntry:
	var initials: String
	var score: int
	func _init(_initials: String, _score: int):
		initials = _initials
		score = _score
	func equals(other: ScoreEntry) -> bool:
		return initials == other.initials && score == other.score
	func get_score_text() -> String:
		return tr("SCORE_DISTANCE_TEXT").format({"distance_score": str(score / 100.0).pad_decimals(2)})

func store_score(initials: String) -> void:
	_current_initials = initials
	
	var file := FileAccess.open(SCORES_FILENAME, FileAccess.READ_WRITE)
	if !file:
		file = FileAccess.open(SCORES_FILENAME, FileAccess.WRITE)
	file.seek_end()
	var entry := get_current_score()
	file.store_string(entry.initials)
	file.store_32(entry.score)

func get_scores() -> Array[ScoreEntry]:
	var file := FileAccess.open(SCORES_FILENAME, FileAccess.READ)
	var scores: Array[ScoreEntry] = []
	while file && file.get_position() < file.get_length():
		scores.push_back(ScoreEntry.new(
			file.get_buffer(3).get_string_from_utf8(),
			file.get_32()))
	scores.sort_custom(func (a, b): return a.score > b.score)
	return scores

func get_current_score() -> ScoreEntry:
	return ScoreEntry.new(_current_initials, int(_distance_traveled * 100))

func get_hiscore() -> ScoreEntry:
	var scores := get_scores()
	if scores.size() > 0:
		return get_scores()[0]
	else:
		return null
