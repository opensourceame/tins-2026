class_name SolarSystem
extends Node2D

var planets = []

func _ready():
    for _i in range(randi_range(1, 5)):
        add_planet()

    queue_redraw()

func _draw():
    for planet in planets:
        draw_circle(planet.pos, planet.size, planet.color)

func add_planet():
    var planet = {
        "pos": Vector2(randi_range(-500, 500), randi_range(-500, 500)),
        "size": randi_range(100, 500),
        "color": Color.RED
    }
    planets.append(planet)
