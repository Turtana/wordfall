extends Node2D

export (PackedScene) var Bubble
export var bubble_offset = 64
export var next_character_limit = 4
var bubble_width_range
var alphabet = "qwerty"
var alphabet_balanced
var word_database
var current_word = 0
var score = 0
var game_speed = 250

var time_bar
var time_bar_width
var timer
var timer_coefficient

var bubble_list = []

func _ready():
	bubble_width_range = get_viewport_rect().size.x - bubble_offset * 2
	randomize()
	alphabet_balanced = alphabet
	
	var file = File.new()
	file.open("res://words.json", file.READ)
	var content = parse_json(file.get_as_text())
	file.close()
	word_database = []
	for word in content:
		word_database.append(word.to_upper())
	word_database.shuffle()
	set_new_word(word_database[current_word])
	
	$BottomPanel/NewScorePanel.visible = false
	time_bar = $BottomPanel/TimeBar
	timer = $HealthTimer
	time_bar_width = time_bar.rect_size.x
	timer_coefficient = 1 / timer.time_left

func _process(_delta):
	time_bar.rect_size.x = timer.time_left * timer_coefficient * time_bar_width

func _on_BubbleSpawnTimer_timeout():
	var bubble = Bubble.instance()
	bubble.alphabet = alphabet_balanced
	bubble.speed = game_speed
	$GameSpace.add_child(bubble)
	bubble_list.append(bubble)
	var bubble_x = rand_range(bubble_offset, bubble_width_range + bubble_offset)
	bubble.position = Vector2(bubble_x, -bubble_offset)
	bubble.connect("burst", self, "bubble_burst")
	bubble.connect("remove", self, "remove")

func set_new_word(word):
	$BottomPanel/WordComplete.visible_characters = 0
	$BottomPanel/WordComplete.text = word
	$BottomPanel/WordTemplate.text = word
	alphabet = word
	alphabet_balanced = alphabet.substr(0, next_character_limit)

func word_complete():
	$Success.play()
	set_score(len(alphabet) * 100)
	current_word += 1
	set_new_word(word_database[current_word])
	game_speed += 30
	timer.start(1 / timer_coefficient)

func set_score(points):
	score += points
	$TopPanel/Score.text = str(score)
	
	var foresign = "+"
	if points < 0:
		foresign = ""
	$BottomPanel/NewScorePanel/Score.text = foresign + str(points)
	$BottomPanel/NewScorePanel.visible = true
	$NewScoreTimer.start()

func bubble_burst(bubble):
	if bubble.get_node("Bubble/Letter").text == alphabet[$BottomPanel/WordComplete.visible_characters]:
		bubble_list.erase(bubble)
		$PopS.play()
		$BottomPanel/WordComplete.visible_characters += 1
		set_score(50)
		if $BottomPanel/WordComplete.visible_characters == len(alphabet):
			word_complete()
		else:
			timer.start(timer.time_left + 1)
			alphabet_balanced = alphabet.substr($BottomPanel/WordComplete.visible_characters, next_character_limit)
	else:
		$PopF.play()
		$BottomPanel/WordComplete.visible_characters = 0
		alphabet_balanced = alphabet.substr(0, next_character_limit)
		set_score(-200)

func _on_NewScoreTimer_timeout():
	$BottomPanel/NewScorePanel.visible = false

func remove(bubble):
	bubble_list.erase(bubble)

func _on_HealthTimer_timeout():
	$Gameover.play()
	$GameOverText.visible = true
	for b in bubble_list:
		b.moving = false
	$BubbleSpawnTimer.stop()
	$BottomPanel/TimeBar.visible = false
