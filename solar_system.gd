class_name SolarSystem
extends Node2D

var MIN_SIZE = 20
var MAX_SIZE = 50

var MIN_DISTANCE = 100
var MAX_DISTANCE = 500

var planets = []

func _ready():
    for _i in range(randi_range(1, 5)):
        add_planet()

    queue_redraw()

func _draw():
    draw_circle(Vector2.ZERO, 100, Color.YELLOW)

    for planet in planets:
        draw_circle(planet.pos, planet.size, planet.color)

func add_planet():
    var planet = {
        "pos": Vector2(randi_range(MIN_DISTANCE, MAX_DISTANCE), randi_range(MIN_DISTANCE / 3, MAX_DISTANCE / 3)),
        "size": randi_range(MIN_SIZE, MAX_SIZE),
        "color": Color.RED
    }
    planets.append(planet)
