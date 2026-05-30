class_name BroadcastingComponent
extends Node2D

const MIN_RADIUS = 60
const MAX_RADIUS = 500
const GAP = 20
const SPEED = 20

var planet_data
var radius = MIN_RADIUS

func _ready():
    var parent = get_parent()
    if parent is Planet:
        planet_data = parent
    else:
        if parent.planets.is_empty():
            await parent.planets_generated
        var planets = parent.planets.slice(1)
        if planets.is_empty():
            return
        planet_data = planets.pick_random()

func _physics_process(delta: float) -> void:
    radius += SPEED * delta
    if radius > MAX_RADIUS:
        radius = 0
    queue_redraw()

func _draw():
    if not planet_data:
        return

    for r in range(MIN_RADIUS, radius, GAP):
        draw_circle(Vector2.ZERO, r, Color(0.268, 0.268, 0.268, 1.7 - 1.0 * radius / MAX_RADIUS), false, 1)
