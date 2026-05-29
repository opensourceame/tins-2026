class_name BroadcastingComponent
extends Node2D

const MAX_RADIUS = 500

var planet
var radius = 0

func _ready():
    await get_parent().add_planets

    planet = get_parent().planets.pick_random()

func _physics_process(delta: float) -> void:
    queue_redraw()

func _draw():
    if not planet:
        return

    for i in range(5):
        var r = i * 10

        draw_circle(planet.position, radius, Color.DARK_GRAY)
