extends Area2D

signal burst(bubble)
signal remove(bubble)

export var alphabet = "abcdefghijklmnopqrstuvwxyz"

var speed = 300
var moving = true
var screen_height

func _ready():
	$Tween.interpolate_property($Bubble, "scale", null, Vector2(2.0, 2.0), 0.5, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.interpolate_property($Bubble, "modulate", null, Color(1,1,1,0), 0.5, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Bubble/Letter.text = alphabet[randi() % len(alphabet)].to_upper()
	screen_height = get_viewport_rect().size.y + 64

func _process(delta):
	if moving:
		position.y += speed * delta
	if position.y > screen_height:
		emit_signal("remove", self)
		queue_free()

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton \
    and event.button_index == BUTTON_LEFT \
    and event.is_pressed():
		click()

func click():
	moving = false
	emit_signal("burst", self)
	$Tween.start()

func _on_Tween_tween_completed(_object, _key):
	queue_free()