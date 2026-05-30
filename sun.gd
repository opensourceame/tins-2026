class_name Sun
extends StaticBody2D

@onready var particles: GPUParticles2D = $Particles
@onready var circle: Polygon2D = $Circle

const PULSE_TIME = 3.0

var circle_modulation: Color = Color.BLACK

func _ready():
    particles.emitting = true
    #pulse_in()
    #queue_redraw()

func _draw():
    draw_circle(Vector2.ZERO, 128, Color.YELLOW * circle_modulation)

func pulse_in():
    var tween = create_tween()
    #tween.tween_method(circle_modulation, Color.WHITE, Color.BLACK, PULSE_TIME)
    tween.tween_property(self, "circle_modulation", Color.WHITE, PULSE_TIME)
    tween.tween_callback(pulse_out)

func pulse_out():
    var tween = create_tween()
    tween.tween_property(circle, "modulate", Color.WHITE, PULSE_TIME)
    tween.tween_callback(pulse_in)
