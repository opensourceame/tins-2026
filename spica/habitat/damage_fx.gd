class_name SpineDamageFX
extends Node

const ROCK_TIME: float = 1.0
const PULSE_TIME: float = 1.0

@onready var parent = get_parent()

func _ready():
    pulse_in()

func rock_clockwise():
    var t = create_tween()
    t.tween_property(parent, "rotation", parent.rotation + deg_to_rad(random_rock_amount()), random_rock_time())
    t.tween_callback(rock_anticlockwise)

func rock_anticlockwise():
    var t = create_tween()
    t.tween_property(parent, "rotation", parent.rotation - deg_to_rad(random_rock_amount()), random_rock_time())
    t.tween_callback(rock_anticlockwise)

func random_rock_amount():
    return randi_range(5, 10)

func random_rock_time():
    return ROCK_TIME / 2 + (ROCK_TIME / 2 * randf())

func pulse_in():
    var tween = create_tween()
    #tween.tween_method(circle_modulation, Color.WHITE, Color.BLACK, PULSE_TIME)
    tween.tween_property(parent, "modulate", Color.WHITE * 2, PULSE_TIME)
    tween.tween_callback(pulse_out)

func pulse_out():
    var tween = create_tween()
    tween.tween_property(parent, "modulate", Color.WHITE, PULSE_TIME)
    tween.tween_callback(pulse_in)
