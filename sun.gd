class_name Sun
extends StaticBody2D

@onready var particles: GPUParticles2D = $Particles
@onready var circle: Polygon2D = $Circle

const PULSE_TIME = 3.0


func _ready():
    particles.emitting = true
    pulse_in()

func pulse_in():
    var tween = create_tween()
    tween.tween_property(circle, "modulate", Color.WHITE * 1.5, PULSE_TIME)
    tween.tween_callback(pulse_out)

func pulse_out():
    var tween = create_tween()
    tween.tween_property(circle, "modulate", Color.WHITE, PULSE_TIME)
    tween.tween_callback(pulse_in)
